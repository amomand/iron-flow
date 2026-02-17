import Foundation

@Observable
class RoutineStore {
    var routines: [Routine] = []

    private let fileURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("routines.json")
    }()

    init() {
        load()
        if routines.isEmpty {
            routines = Self.seedRoutines()
            save()
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(routines)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save routines: \(error)")
        }
    }

    func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            routines = try JSONDecoder().decode([Routine].self, from: data)
        } catch {
            print("Failed to load routines: \(error)")
        }
    }

    func addRoutine(_ routine: Routine) {
        routines.append(routine)
        save()
    }

    func updateRoutine(_ routine: Routine) {
        if let idx = routines.firstIndex(where: { $0.id == routine.id }) {
            routines[idx] = routine
            save()
        }
    }

    func deleteRoutine(at offsets: IndexSet) {
        routines.remove(atOffsets: offsets)
        save()
    }

    func exportRoutineJSON(_ routine: Routine) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(routine) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func importRoutineFromJSON(_ json: String) -> Result<Routine, ImportError> {
        guard let data = json.data(using: .utf8) else {
            return .failure(.invalidJSON)
        }
        do {
            var routine = try JSONDecoder().decode(Routine.self, from: data)
            // Assign new IDs so imports never collide with existing routines
            routine.id = UUID()
            for si in routine.sections.indices {
                routine.sections[si].id = UUID()
                for ei in routine.sections[si].exercises.indices {
                    routine.sections[si].exercises[ei].id = UUID()
                }
            }
            routines.append(routine)
            save()
            return .success(routine)
        } catch {
            return .failure(.decodingFailed(error.localizedDescription))
        }
    }

    enum ImportError: LocalizedError {
        case invalidJSON
        case decodingFailed(String)

        var errorDescription: String? {
            switch self {
            case .invalidJSON: return "Clipboard does not contain valid text."
            case .decodingFailed(let msg): return "Could not parse routine: \(msg)"
            }
        }
    }

    // MARK: - Seed Data

    static func seedRoutines() -> [Routine] {
        [sessionA(), sessionB()]
    }

    private static func sessionA() -> Routine {
        Routine(name: "Session A: Horizontal Push / Row Focus", sections: [
            Section(name: "Warm-up", exercises: [
                ExerciseBlock(name: "Arm circles", sets: 1, reps: 10, restBetweenSetsSeconds: 0, restAfterExerciseSeconds: 0, notes: "Each direction"),
                ExerciseBlock(name: "Kettlebell halos (14kg)", sets: 1, reps: 8, restBetweenSetsSeconds: 0, restAfterExerciseSeconds: 0, notes: "Each direction"),
                ExerciseBlock(name: "Scapular push-ups", sets: 1, reps: 10, restBetweenSetsSeconds: 0, restAfterExerciseSeconds: 0, notes: ""),
                ExerciseBlock(name: "Shoulder dislocates / band pull-aparts", sets: 1, reps: 10, restBetweenSetsSeconds: 0, restAfterExerciseSeconds: 0, notes: ""),
            ]),
            Section(name: "Strength Block", exercises: [
                ExerciseBlock(name: "Chair dips", sets: 4, reps: 8, restBetweenSetsSeconds: 90, restAfterExerciseSeconds: 120, notes: "Tempo: 3 sec down, pause, explode up. Progress by adding 10kg dumbbell in lap."),
                ExerciseBlock(name: "Single-arm KB row (24kg)", sets: 3, reps: 10, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Brace hard, pull elbow to hip, squeeze at top.", perSide: true),
            ]),
            Section(name: "Hypertrophy Block", exercises: [
                ExerciseBlock(name: "Incline press-ups (feet elevated)", sets: 3, reps: 12, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Slow eccentric to 4 sec if too easy."),
                ExerciseBlock(name: "KB floor press (24kg)", sets: 3, reps: 10, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Single arm, opposite leg bent for stability.", perSide: true),
                ExerciseBlock(name: "Hammer curls (10kg)", sets: 3, reps: 10, restBetweenSetsSeconds: 45, restAfterExerciseSeconds: 75, notes: "Standing, controlled, no swing."),
            ]),
            Section(name: "Core Finisher", exercises: [
                ExerciseBlock(name: "Dead bugs", sets: 3, reps: 8, restBetweenSetsSeconds: 15, restAfterExerciseSeconds: 15, notes: "", perSide: true),
                ExerciseBlock(name: "Hollow body hold", sets: 2, reps: 20, restBetweenSetsSeconds: 15, restAfterExerciseSeconds: 15, notes: "Seconds hold"),
            ]),
        ])
    }

    private static func sessionB() -> Routine {
        Routine(name: "Session B: Overhead / Vertical Focus", sections: [
            Section(name: "Warm-up", exercises: [
                ExerciseBlock(name: "Stretch", sets: 1, reps: 1, restBetweenSetsSeconds: 0, restAfterExerciseSeconds: 0, notes: ""),
                ExerciseBlock(name: "Kettlebell halos (14kg)", sets: 2, reps: 8, restBetweenSetsSeconds: 0, restAfterExerciseSeconds: 0, notes: "Each direction"),
                ExerciseBlock(name: "Cat-cow", sets: 1, reps: 10, restBetweenSetsSeconds: 0, restAfterExerciseSeconds: 0, notes: ""),
            ]),
            Section(name: "Strength Block", exercises: [
                ExerciseBlock(name: "Pike press-ups", sets: 4, reps: 8, restBetweenSetsSeconds: 90, restAfterExerciseSeconds: 120, notes: "Feet on chair for difficulty. Head touches floor between hands. Handstand push-up progression."),
                ExerciseBlock(name: "KB high pull (24kg)", sets: 3, reps: 10, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Explosive hip hinge, elbows high and wide. Not an upright row."),
            ]),
            Section(name: "Hypertrophy Block", exercises: [
                ExerciseBlock(name: "Single-arm KB press (14kg or 24kg)", sets: 3, reps: 8, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Standing, brace core, strict press.", perSide: true),
                ExerciseBlock(name: "Archer press-ups", sets: 3, reps: 6, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Wide base, shift weight to working arm. One-arm push-up progression.", perSide: true),
                ExerciseBlock(name: "KB curl (14kg, two-handed on horns)", sets: 3, reps: 12, restBetweenSetsSeconds: 45, restAfterExerciseSeconds: 75, notes: "Or single-arm with 10kg dumbbell."),
            ]),
            Section(name: "Core Finisher", exercises: [
                ExerciseBlock(name: "Turkish get-up (14kg)", sets: 2, reps: 1, restBetweenSetsSeconds: 120, restAfterExerciseSeconds: 120, notes: "Worth the price of admission alone. Take your time.", perSide: true),
            ]),
        ])
    }
}
