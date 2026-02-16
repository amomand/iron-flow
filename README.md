# IronFlow

A personal iOS workout timer app built with SwiftUI. Designed for side-loading via Xcode — not for the App Store.

Replaces the workflow of checking Obsidian notes mid-workout with a swipe-driven interface that handles rest timers, exercise progression, and difficulty tracking automatically.

## What It Does

1. **Pick a routine** from the home screen
2. **Swipe left** through exercises — each card shows the exercise, set/rep info, and notes
3. **Rate each set** before swiping: ❌ Fail / ✅ Good / 🔥 Too Easy
4. **Rest timer** counts down automatically between sets with haptic feedback
5. **Summary** at the end shows only flagged exercises — copy as markdown to paste into Obsidian

## Tech

- **Pure SwiftUI** — zero dependencies, no pods, no SPM packages
- **iOS 17+** target, portrait only
- **Data stored as JSON** in the app's documents directory
- **TokyoNight Night** terminal aesthetic — monospaced font, dark background, neon accents

## Project Structure

```
IronFlow/
├── IronFlowApp.swift              # App entry point
├── Theme/
│   ├── TokyoNightColors.swift     # TN.bg, TN.blue, TN.red, etc.
│   └── TerminalStyle.swift        # Shared fonts, button styles, card modifier
├── Models/
│   ├── Routine.swift              # Routine → Section → ExerciseBlock
│   ├── SetRating.swift            # .couldNotComplete / .good / .tooEasy
│   └── WorkoutSession.swift       # Live workout state, results, summary generation
├── Storage/
│   └── RoutineStore.swift         # JSON persistence + seed data (Session A & B)
└── Views/
    ├── RoutineListView.swift      # Home screen
    ├── Workout/
    │   ├── WorkoutFlowView.swift  # Orchestrates exercise → rest → next
    │   ├── ExerciseCardView.swift # Exercise display + rating + swipe gesture
    │   ├── RestTimerView.swift    # Countdown timer with progress ring
    │   └── WorkoutSummaryView.swift # End-of-workout report + clipboard copy
    └── Editor/
        ├── RoutineEditorView.swift    # Edit routine sections & exercises
        └── ExerciseEditorView.swift   # Edit individual exercise details
```

## Building & Deploying

Open `IronFlow.xcodeproj` in Xcode, select your iPhone as the destination, and hit ⌘R.

- **Free Apple Developer account**: app expires every 7 days, re-deploy to refresh
- **Paid account ($99/yr)**: lasts a year

## Seed Data

Ships with two routines pulled from Obsidian training notes:

- **Session A**: Horizontal Push / Row Focus (warm-up → chair dips, KB rows → incline press-ups, KB floor press, hammer curls → dead bugs, hollow body hold)
- **Session B**: Overhead / Vertical Focus (warm-up → pike press-ups, KB high pull → KB press, archer press-ups, KB curls → Turkish get-ups)

These can be edited in-app or by modifying `RoutineStore.swift`.
