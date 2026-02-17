import Foundation

struct SetResult: Identifiable, Codable {
    let id: UUID
    let exerciseId: UUID
    let exerciseName: String
    let setNumber: Int
    let rating: SetRating
    let completedAt: Date

    init(exerciseId: UUID, exerciseName: String, setNumber: Int, rating: SetRating) {
        self.id = UUID()
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.setNumber = setNumber
        self.rating = rating
        self.completedAt = Date()
    }
}

struct RoutineAdjustment: Identifiable {
    let id = UUID()
    let exerciseName: String
    let field: String          // "reps" or "sets"
    let oldValue: Int
    let newValue: Int
}

@Observable
class WorkoutSession {
    let routine: Routine
    let steps: [WorkoutStep]
    var currentStepIndex: Int = 0
    var selectedRating: SetRating = .good
    var results: [SetResult] = []
    var isResting: Bool = false
    var isFinished: Bool = false
    let startedAt: Date
    var adjustments: [RoutineAdjustment] = []

    var currentStep: WorkoutStep? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }

    var nextStep: WorkoutStep? {
        let nextIndex = currentStepIndex + 1
        guard nextIndex < steps.count else { return nil }
        return steps[nextIndex]
    }

    var progress: Double {
        guard !steps.isEmpty else { return 1.0 }
        return Double(currentStepIndex) / Double(steps.count)
    }

    var estimatedMinutesRemaining: Int {
        guard currentStepIndex < steps.count else { return 0 }
        let remaining = steps[currentStepIndex..<steps.count]
        let totalSeconds = remaining.reduce(0) { total, step in
            total + 30 + step.restSeconds  // ~30s per active set + rest
        }
        return max(1, (totalSeconds + 30) / 60)  // round up
    }

    init(routine: Routine) {
        self.routine = routine
        self.steps = routine.buildSteps()
        self.startedAt = Date()
    }

    func completeCurrentSet() {
        guard let step = currentStep else { return }
        let result = SetResult(
            exerciseId: step.exercise.id,
            exerciseName: step.exercise.name,
            setNumber: step.setNumber,
            rating: selectedRating
        )
        results.append(result)

        if step.restSeconds > 0 && currentStepIndex < steps.count - 1 {
            isResting = true
        } else {
            advanceToNextStep()
        }
    }

    func advanceToNextStep() {
        isResting = false
        selectedRating = .good
        currentStepIndex += 1
        if currentStepIndex >= steps.count {
            isFinished = true
            adjustments = computeAdjustments()
        }
    }

    // MARK: - Adjustment Engine

    func computeAdjustments() -> [RoutineAdjustment] {
        var adj: [RoutineAdjustment] = []

        // Group results by exercise ID
        let grouped = Dictionary(grouping: results) { $0.exerciseId }

        for section in routine.sections {
            for exercise in section.exercises {
                guard exercise.sets > 1 else { continue }  // skip single-set (warm-ups)
                guard let exerciseResults = grouped[exercise.id], !exerciseResults.isEmpty else { continue }

                let total = exerciseResults.count
                let fails = exerciseResults.filter { $0.rating == .couldNotComplete }.count
                let easies = exerciseResults.filter { $0.rating == .tooEasy }.count

                let failRatio = Double(fails) / Double(total)
                let easyRatio = Double(easies) / Double(total)

                if failRatio >= 0.5 {
                    // Too hard: reduce reps first, then sets
                    if exercise.reps > 5 {
                        let drop = failRatio >= 0.75 ? 2 : 1
                        let newReps = max(5, exercise.reps - drop)
                        if newReps != exercise.reps {
                            adj.append(RoutineAdjustment(
                                exerciseName: exercise.name, field: "reps",
                                oldValue: exercise.reps, newValue: newReps
                            ))
                        }
                    } else if exercise.sets > 2 {
                        adj.append(RoutineAdjustment(
                            exerciseName: exercise.name, field: "sets",
                            oldValue: exercise.sets, newValue: exercise.sets - 1
                        ))
                    }
                } else if easyRatio >= 0.75 {
                    // Too easy: increase reps first, then sets
                    if exercise.reps < 20 {
                        let bump = easyRatio >= 1.0 ? 2 : 1
                        let newReps = min(20, exercise.reps + bump)
                        if newReps != exercise.reps {
                            adj.append(RoutineAdjustment(
                                exerciseName: exercise.name, field: "reps",
                                oldValue: exercise.reps, newValue: newReps
                            ))
                        }
                    } else if exercise.sets < 6 {
                        adj.append(RoutineAdjustment(
                            exerciseName: exercise.name, field: "sets",
                            oldValue: exercise.sets, newValue: exercise.sets + 1
                        ))
                    }
                }
            }
        }

        return adj
    }

    func applyAdjustments(to routine: inout Routine) {
        for adjustment in adjustments {
            for si in routine.sections.indices {
                for ei in routine.sections[si].exercises.indices {
                    if routine.sections[si].exercises[ei].name == adjustment.exerciseName {
                        if adjustment.field == "reps" {
                            routine.sections[si].exercises[ei].reps = adjustment.newValue
                        } else if adjustment.field == "sets" {
                            routine.sections[si].exercises[ei].sets = adjustment.newValue
                        }
                    }
                }
            }
        }
    }

    func generateSummaryMarkdown() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: startedAt)

        var md = "## Workout Summary — \(routine.name)\n"
        md += "**Date:** \(dateStr)\n\n"

        let fails = results.filter { $0.rating == .couldNotComplete }
        let easies = results.filter { $0.rating == .tooEasy }

        if fails.isEmpty && easies.isEmpty && adjustments.isEmpty {
            md += "All sets completed as expected. No adjustments needed.\n"
            return md
        }

        if !fails.isEmpty {
            md += "### ❌ Needs Attention\n"
            let grouped = Dictionary(grouping: fails) { $0.exerciseName }
            for (name, sets) in grouped.sorted(by: { $0.key < $1.key }) {
                let setNums = sets.map { "Set \($0.setNumber)" }.joined(separator: ", ")
                md += "- **\(name)** — \(setNums): Couldn't complete\n"
            }
            md += "\n"
        }

        if !easies.isEmpty {
            md += "### 🪶 Too Easy (Consider Progressing)\n"
            let grouped = Dictionary(grouping: easies) { $0.exerciseName }
            for (name, sets) in grouped.sorted(by: { $0.key < $1.key }) {
                let totalSetsForExercise = results.filter { $0.exerciseName == name }.count
                if sets.count == totalSetsForExercise {
                    md += "- **\(name)** — All sets\n"
                } else {
                    let setNums = sets.map { "Set \($0.setNumber)" }.joined(separator: ", ")
                    md += "- **\(name)** — \(setNums): Too easy\n"
                }
            }
            md += "\n"
        }

        if !adjustments.isEmpty {
            md += "### 📐 Adjustments Applied\n"
            for a in adjustments {
                md += "- **\(a.exerciseName)** — \(a.field): \(a.oldValue) → \(a.newValue)\n"
            }
        }

        return md
    }
}
