import Foundation

@Observable
class RoutineStore {
    var routines: [Routine] = []
    private static let seedVersion = "summer-arc-strength-v1"
    private static let seedVersionKey = "RoutineStore.seedVersion"

    private let fileURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("routines.json")
    }()

    init() {
        load()
        migrateSeedRoutinesIfNeeded()
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
    //
    // Source of truth: "Training Plan - Summer Arc.md" (Obsidian / Fitness folder).
    // Only the two strength maintenance sessions are seeded here.

    static func seedRoutines() -> [Routine] {
        [lowerMaintenance(), upperMaintenance()]
    }

    private func migrateSeedRoutinesIfNeeded() {
        let defaults = UserDefaults.standard
        let appliedVersion = defaults.string(forKey: Self.seedVersionKey)

        guard appliedVersion != Self.seedVersion else {
            if routines.isEmpty {
                routines = Self.seedRoutines()
                save()
            }
            return
        }

        if routines.isEmpty || Self.matchesLegacySeedRoutines(routines) {
            routines = Self.seedRoutines()
            save()
        }

        defaults.set(Self.seedVersion, forKey: Self.seedVersionKey)
    }

    private static func matchesLegacySeedRoutines(_ routines: [Routine]) -> Bool {
        let legacyNames: Set<String> = [
            "Upper A — Push and Row",
            "Lower A — Squat and Hinge",
            "Upper B — Shoulder and Pull",
            "Lower B — Unilateral and Posterior Chain",
        ]

        guard routines.count == legacyNames.count else {
            return false
        }

        let routineNames = Set(routines.map(\.name))
        return routineNames == legacyNames
    }

    private static func lowerMaintenance() -> Routine {
        Routine(name: "Wednesday — Lower Maintenance", sections: [
            Section(name: "Maintenance", exercises: [
                ExerciseBlock(
                    name: "Goblet squats (24kg)",
                    sets: 2, reps: 8,
                    restBetweenSetsSeconds: 90, restAfterExerciseSeconds: 90,
                    notes: "Slow eccentric."
                ),
                ExerciseBlock(
                    name: "Romanian deadlifts (24kg KB)",
                    sets: 2, reps: 10,
                    restBetweenSetsSeconds: 90, restAfterExerciseSeconds: 90,
                    notes: "Hips back, flat back, controlled stretch."
                ),
                ExerciseBlock(
                    name: "Bulgarian split squats (10kg dumbbells)",
                    sets: 2, reps: 8,
                    restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 60,
                    notes: "Rear foot on chair.",
                    perSide: true,
                ),
                ExerciseBlock(
                    name: "Standing calf raises (24kg KB)",
                    sets: 2, reps: 15,
                    restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 60,
                    notes: "Full range, slow."
                ),
                ExerciseBlock(
                    name: "Front plank",
                    sets: 2, reps: 30, durationSeconds: 30,
                    restBetweenSetsSeconds: 30, restAfterExerciseSeconds: 30,
                    notes: "Timed hold."
                ),
            ]),
        ])
    }

    private static func upperMaintenance() -> Routine {
        Routine(name: "Sunday — Upper Maintenance", sections: [
            Section(name: "Maintenance", exercises: [
                ExerciseBlock(
                    name: "Floor press KB (24kg)",
                    sets: 2, reps: 10,
                    restBetweenSetsSeconds: 90, restAfterExerciseSeconds: 90,
                    notes: "Two-handed grip."
                ),
                ExerciseBlock(
                    name: "Single-arm KB row (24kg)",
                    sets: 2, reps: 10,
                    restBetweenSetsSeconds: 90, restAfterExerciseSeconds: 90,
                    notes: "Brace hard, elbow to hip.",
                    perSide: true,
                ),
                ExerciseBlock(
                    name: "Standing single-arm KB press (14kg)",
                    sets: 2, reps: 6,
                    restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 60,
                    notes: "Strict press.",
                    perSide: true
                ),
                ExerciseBlock(
                    name: "Push-ups",
                    sets: 2, reps: 10,
                    restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 60,
                    notes: "Full range."
                ),
                ExerciseBlock(
                    name: "Hammer curls (10kg dumbbells)",
                    sets: 2, reps: 10,
                    restBetweenSetsSeconds: 60, restAfterExerciseSeconds: 60,
                    notes: "No swing."
                ),
                ExerciseBlock(
                    name: "Sit-ups",
                    sets: 2, reps: 12,
                    restBetweenSetsSeconds: 30, restAfterExerciseSeconds: 30,
                    notes: "Core finisher."
                ),
            ]),
        ])
    }
}
