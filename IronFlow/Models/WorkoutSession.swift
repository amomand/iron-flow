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

    var currentStep: WorkoutStep? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }

    var progress: Double {
        guard !steps.isEmpty else { return 1.0 }
        return Double(currentStepIndex) / Double(steps.count)
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

        if step.exercise.restSeconds > 0 && currentStepIndex < steps.count - 1 {
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

        if fails.isEmpty && easies.isEmpty {
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
            md += "### 🔥 Too Easy (Consider Progressing)\n"
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
        }

        return md
    }
}
