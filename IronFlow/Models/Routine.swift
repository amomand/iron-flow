import Foundation

struct Routine: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var sections: [Section]

    init(id: UUID = UUID(), name: String, sections: [Section] = []) {
        self.id = id
        self.name = name
        self.sections = sections
    }
}

struct Section: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var exercises: [ExerciseBlock]

    init(id: UUID = UUID(), name: String, exercises: [ExerciseBlock] = []) {
        self.id = id
        self.name = name
        self.exercises = exercises
    }
}

struct ExerciseBlock: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var sets: Int
    var reps: String
    var restSeconds: Int
    var notes: String
    var perSide: Bool

    init(
        id: UUID = UUID(),
        name: String,
        sets: Int = 3,
        reps: String = "10",
        restSeconds: Int = 60,
        notes: String = "",
        perSide: Bool = false
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.restSeconds = restSeconds
        self.notes = notes
        self.perSide = perSide
    }
}

// Flattened step for the workout flow
struct WorkoutStep: Identifiable {
    let id = UUID()
    let sectionName: String
    let exercise: ExerciseBlock
    let setNumber: Int
    let isFirstInSection: Bool
}

extension Routine {
    func buildSteps() -> [WorkoutStep] {
        var steps: [WorkoutStep] = []
        for section in sections {
            for (exerciseIndex, exercise) in section.exercises.enumerated() {
                for setNum in 1...max(exercise.sets, 1) {
                    steps.append(WorkoutStep(
                        sectionName: section.name,
                        exercise: exercise,
                        setNumber: setNum,
                        isFirstInSection: exerciseIndex == 0 && setNum == 1
                    ))
                }
            }
        }
        return steps
    }
}
