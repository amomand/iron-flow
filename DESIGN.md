# IronFlow — Design & Architecture

Reference document for future development sessions.

## Design Principles

- **Terminal aesthetic**: TokyoNight Night palette, SF Mono throughout, UI elements styled as terminal constructs (`// SECTION HEADERS`, `[ BUTTON LABELS ]`, comment-coloured secondary text)
- **Minimal interaction during workout**: swipe left to advance, tap to rate — nothing else needed
- **No audio**: the app never touches the audio session, so Apple Music plays uninterrupted
- **Screen stays on**: idle timer disabled during active workouts, re-enabled on exit
- **Obsidian-friendly output**: summary copies as markdown with headers, bold, and emoji

## Data Model

```
Routine (Codable, stored as JSON in app documents dir)
├── id: UUID
├── name: String
└── sections: [Section]
      ├── id: UUID
      ├── name: String
      └── exercises: [ExerciseBlock]
            ├── id: UUID
            ├── name: String
            ├── sets: Int
            ├── reps: Int
            ├── restBetweenSetsSeconds: Int
            ├── restAfterExerciseSeconds: Int
            ├── notes: String
            └── perSide: Bool         ← flags "each side" exercises

WorkoutSession (in-memory only, not persisted)
├── routine: Routine
├── steps: [WorkoutStep]              ← flattened list of every individual set
├── currentStepIndex: Int
├── selectedRating: SetRating
├── results: [SetResult]
├── adjustments: [RoutineAdjustment]  ← computed on workout completion
├── isResting: Bool
└── isFinished: Bool

WorkoutStep
├── sectionName: String
├── exercise: ExerciseBlock
├── setNumber: Int
├── isFirstInSection: Bool
├── isLastSetOfExercise: Bool
└── restSeconds: Int (computed)       ← picks between-sets or after-exercise rest

RoutineAdjustment
├── exerciseName: String
├── field: String ("reps" or "sets")
├── oldValue: Int
└── newValue: Int
```

## Screen Flow

```
RoutineListView → (tap) → WorkoutFlowView
                              ├── ExerciseCardView (swipe left to complete)
                              │     └── [list icon] → RoutineOverviewSheet
                              ├── RestTimerView (auto-advances or skip)
                              │     └── [list icon] → RoutineOverviewSheet
                              └── WorkoutSummaryView (adjustments + copy + done)
                → (edit) → RoutineEditorView → ExerciseEditorView
```

## TokyoNight Colour Reference

| Token      | Hex       | Usage                          |
|------------|-----------|--------------------------------|
| `TN.bg`    | `#1a1b26` | App background                 |
| `TN.card`  | `#24283b` | Card surfaces                  |
| `TN.darkCard` | `#1f2335` | Input fields, subtle surfaces |
| `TN.fg`    | `#c0caf5` | Primary text                   |
| `TN.comment` | `#565f89` | Secondary text, hints         |
| `TN.blue`  | `#7aa2f7` | Accent, active elements        |
| `TN.green` | `#9ece6a` | Success, "good" rating         |
| `TN.yellow`| `#e0af68` | Warning, "too easy" rating     |
| `TN.red`   | `#f7768e` | Error, "fail" rating           |
| `TN.purple`| `#bb9af7` | Section headers                |
| `TN.orange`| `#ff9e64` | "Per side" labels              |

## Key Behaviours

- **Default rating is `.good`** — swiping without tapping a rating counts as good
- **Warm-up exercises**: `sets: 1`, `restBetweenSetsSeconds: 0` — swipe straight through
- **"Minimal" rest** from Obsidian mapped to 15 seconds
- **"Take your time"** (Turkish get-ups) mapped to 120 seconds
- **Split rest timers**: `restBetweenSetsSeconds` for rest between sets; `restAfterExerciseSeconds` for rest after the last set of an exercise (typically 30s longer)
- **Summary only shows flagged exercises** — all-good sets are omitted
- **Haptic on rest end**: `UINotificationFeedbackGenerator.success`
- **Automatic difficulty adjustment**: after workout, exercises with ≥50% FAIL ratings get reps/sets reduced; ≥75% EASY ratings get reps/sets increased. Adjustments auto-save and appear in summary.
- **Rest timer shows "next:" label** — displays the upcoming exercise name, not the one just completed
- **Time remaining estimate** — shown during workout as "~N min left"
- **Mid-workout routine overview** — tap list icon to see full routine with completed/current/upcoming steps; rest timer continues in background

## Potential Future Features

These have been discussed or may be useful:

- [x] Progression tracking — auto-adjust reps/sets based on workout ratings
- [ ] Workout history — persist summaries with dates for trend tracking
- [ ] Pull-up bar exercises — swap in pull-ups, chin-ups, hanging leg raises when bar arrives
- [ ] Import from Obsidian — paste markdown or read routine files directly
- [ ] Superset support — alternate exercises within a block before resting
- [ ] Widget — show next scheduled workout day on home screen
- [ ] Watch companion — haptic on wrist when rest ends, minimal set counter
