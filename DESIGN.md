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
            ├── reps: String          ← string to support ranges like "6-10"
            ├── restSeconds: Int
            ├── notes: String
            └── perSide: Bool         ← flags "each side" exercises

WorkoutSession (in-memory only, not persisted)
├── routine: Routine
├── steps: [WorkoutStep]              ← flattened list of every individual set
├── currentStepIndex: Int
├── selectedRating: SetRating
├── results: [SetResult]
├── isResting: Bool
└── isFinished: Bool
```

## Screen Flow

```
RoutineListView → (tap) → WorkoutFlowView
                              ├── ExerciseCardView (swipe left to complete)
                              ├── RestTimerView (auto-advances or skip)
                              └── WorkoutSummaryView (copy + done)
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
- **Warm-up exercises**: `sets: 1`, `restSeconds: 0` — swipe straight through
- **"Minimal" rest** from Obsidian mapped to 15 seconds
- **"Take your time"** (Turkish get-ups) mapped to 120 seconds
- **Summary only shows flagged exercises** — all-good sets are omitted
- **Haptic on rest end**: `UINotificationFeedbackGenerator.success`

## Potential Future Features

These have been discussed or may be useful:

- [ ] Workout history — persist summaries with dates for trend tracking
- [ ] Pull-up bar exercises — swap in pull-ups, chin-ups, hanging leg raises when bar arrives
- [ ] Import from Obsidian — paste markdown or read routine files directly
- [ ] Superset support — alternate exercises within a block before resting
- [ ] Progression tracking — auto-suggest when to increase weight/reps based on "too easy" streaks
- [ ] Widget — show next scheduled workout day on home screen
- [ ] Watch companion — haptic on wrist when rest ends, minimal set counter
