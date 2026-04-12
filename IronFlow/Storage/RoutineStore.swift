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
        [sessionA(), sessionB(), sessionC(), sessionD()]
    }

    private static func sessionA() -> Routine {
        Routine(name: "Upper A — Push and Row", sections: [
            Section(name: "Main Lifts", exercises: [
                ExerciseBlock(name: "Floor press KB (24kg)", sets: 3, reps: 10, restBetweenSetsSeconds: 90, restAfterExerciseSeconds: 120, notes: "Two handed grip on the kettlebell."),
                ExerciseBlock(name: "Single-arm KB row (24kg)", sets: 3, reps: 8, restBetweenSetsSeconds: 90, restAfterExerciseSeconds: 120, notes: "Brace hard, pull elbow to hip, squeeze at top.", perSide: true),
            ]),
            Section(name: "Volume Work", exercises: [
                ExerciseBlock(name: "Push-ups", sets: 3, reps: 10, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Full range, no collapsed hips, no rushing."),
                ExerciseBlock(name: "Standing single-arm KB press (14kg)", sets: 3, reps: 6, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Brace core, strict press.", perSide: true),
                ExerciseBlock(name: "Dumbbell lateral raises (10kg)", sets: 2, reps: 10, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Use partial range with strict control. Stop before traps take over. If form breaks, the set is done."),
            ]),
            Section(name: "Core", exercises: [
                ExerciseBlock(name: "Sit-ups", sets: 2, reps: 10, restBetweenSetsSeconds: 30, restAfterExerciseSeconds: 30, notes: ""),
            ]),
        ])
    }

    private static func sessionB() -> Routine {
        Routine(name: "Lower A — Squat and Hinge", sections: [
            Section(name: "Main Lifts", exercises: [
                ExerciseBlock(name: "Goblet squats (24kg)", sets: 3, reps: 6, restBetweenSetsSeconds: 90, restAfterExerciseSeconds: 120, notes: "Slow eccentric so the 24kg keeps biting."),
                ExerciseBlock(name: "Romanian deadlifts (24kg KB)", sets: 3, reps: 8, restBetweenSetsSeconds: 90, restAfterExerciseSeconds: 120, notes: "Hips back, soft knees, flat back, controlled stretch."),
            ]),
            Section(name: "Volume Work", exercises: [
                ExerciseBlock(name: "Bulgarian split squats (10kg dumbbells)", sets: 3, reps: 6, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Rear foot on chair. Control the descent.", perSide: true),
                ExerciseBlock(name: "Kettlebell swings (14kg)", sets: 3, reps: 12, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Clean hinge power, not flailing survival."),
                ExerciseBlock(name: "Standing calf raises (24kg)", sets: 3, reps: 12, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Hold KB and work the full range."),
            ]),
            Section(name: "Core", exercises: [
                ExerciseBlock(name: "Front plank", sets: 2, reps: 30, durationSeconds: 30, restBetweenSetsSeconds: 30, restAfterExerciseSeconds: 30, notes: "Seconds hold."),
            ]),
        ])
    }

    private static func sessionC() -> Routine {
        Routine(name: "Upper B — Shoulder and Pull", sections: [
            Section(name: "Main Lifts", exercises: [
                ExerciseBlock(name: "Single-arm KB row (24kg)", sets: 3, reps: 10, restBetweenSetsSeconds: 90, restAfterExerciseSeconds: 120, notes: "Rows appear twice per week — without pull-ups you need the pulling volume.", perSide: true),
                ExerciseBlock(name: "Standing single-arm KB press (14kg)", sets: 3, reps: 6, restBetweenSetsSeconds: 90, restAfterExerciseSeconds: 120, notes: "Brace core, strict press.", perSide: true),
            ]),
            Section(name: "Volume Work", exercises: [
                ExerciseBlock(name: "Chair dips or close-grip push-ups", sets: 3, reps: 10, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Choose dips only if shoulders feel good and setup is stable. Otherwise, close-grip push-ups are the safer default."),
                ExerciseBlock(name: "Hammer curls (10kg dumbbells)", sets: 3, reps: 8, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Standing, controlled, no swing."),
                ExerciseBlock(name: "Rear delt raise (10kg dumbbells)", sets: 2, reps: 10, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Prioritise control over textbook purity. Use bent-over high row with strict pause if needed."),
            ]),
            Section(name: "Core", exercises: [
                ExerciseBlock(name: "Leg raises", sets: 2, reps: 10, restBetweenSetsSeconds: 30, restAfterExerciseSeconds: 30, notes: ""),
            ]),
        ])
    }

    private static func sessionD() -> Routine {
        Routine(name: "Lower B — Unilateral and Posterior Chain", sections: [
            Section(name: "Strength", exercises: [
                ExerciseBlock(name: "Reverse lunges (10kg dumbbells)", sets: 3, reps: 8, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Unilateral work keeps the load effective even without massive weight.", perSide: true),
                ExerciseBlock(name: "Goblet squats (24kg)", sets: 3, reps: 10, restBetweenSetsSeconds: 90, restAfterExerciseSeconds: 120, notes: "Higher reps than Lower A — volume day."),
                ExerciseBlock(name: "Single-leg Romanian deadlifts (14kg KB)", sets: 3, reps: 8, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Balance and posterior chain.", perSide: true),
            ]),
            Section(name: "Conditioning", exercises: [
                ExerciseBlock(name: "Kettlebell swings (24kg)", sets: 3, reps: 15, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Clean hinge power."),
                ExerciseBlock(name: "Glute bridge (24kg across hips)", sets: 3, reps: 10, restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 90, notes: "Extra posterior-chain work without smashing your lower back after swings."),
            ]),
            Section(name: "Core", exercises: [
                ExerciseBlock(name: "Sit-ups", sets: 2, reps: 10, restBetweenSetsSeconds: 30, restAfterExerciseSeconds: 30, notes: ""),
                ExerciseBlock(name: "Leg raises", sets: 2, reps: 8, restBetweenSetsSeconds: 30, restAfterExerciseSeconds: 30, notes: ""),
            ]),
        ])
    }
}
