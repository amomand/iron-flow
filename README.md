# IronFlow

IronFlow is a personal iOS workout timer app built with SwiftUI. It is designed for side-loading via Xcode, not for App Store distribution.

It replaces checking training notes mid-workout with a low-friction interface for moving through a routine, timing work and rest periods, rating sets, and producing an Obsidian-friendly summary.

## What It Does

1. **Pick a routine** from the home screen.
2. **Follow each set** as a focused card showing the exercise, set count, reps or timed duration, per-side flag, and notes.
3. **Rate rep-based sets** before swiping: Fail, Good, or Easy. Good is the default.
4. **Swipe left to complete** a rep-based set and move into the next rest or exercise.
5. **Run timed exercises** with an automatic countdown and auto-advance at zero.
6. **Rest between sets or exercises** with a countdown, progress ring, skip control, next-exercise label, and vibration when timers complete.
7. **Open the routine overview** mid-workout to see completed, current, and upcoming steps.
8. **Review the workout summary** at the end, including flagged sets and automatic difficulty adjustments.
9. **Copy the summary as Markdown** for pasting into Obsidian or another training log.

## Features

- **Routine editor**: create and edit routines, sections, exercises, sets, reps, timed durations, rest periods, notes, and per-side exercises.
- **JSON import/export**: export routines to the clipboard and import routine JSON generated elsewhere, including from an LLM.
- **Split rest timers**: configure separate rest durations between sets and after the final set of an exercise.
- **Timed exercise support**: use `durationSeconds` for holds or other time-based movements.
- **Automatic progression**: at workout completion, exercises with enough Fail ratings are reduced, and exercises with enough Easy ratings are progressed.
- **Exception-focused summaries**: all-good workouts stay brief; failed, easy, and adjusted exercises are highlighted.
- **Workout-friendly behavior**: the screen stays awake during workouts, and the app avoids audio-session changes so music can keep playing.
- **Terminal-inspired UI**: TokyoNight colors, monospaced type, bracketed controls, and comment-style section headers.

## Data Model

Routines are stored as JSON in the app documents directory:

```text
Routine
├── name
└── sections
    ├── name
    └── exercises
        ├── name
        ├── sets
        ├── reps
        ├── durationSeconds
        ├── restBetweenSetsSeconds
        ├── restAfterExerciseSeconds
        ├── notes
        └── perSide
```

During a workout, `Routine.buildSteps()` flattens the routine into one `WorkoutStep` per set. `WorkoutSession` tracks the current step, ratings, timers, results, summary output, and computed adjustments. Workout sessions are currently in-memory only; historical workout logs are not persisted.

## Tech

- **Pure SwiftUI**: no pods, no Swift Package Manager dependencies.
- **iOS 17+** target.
- **Swift Observation**: uses `@Observable` rather than `ObservableObject`.
- **Local JSON storage**: routines are stored in the app documents directory.
- **Backward-compatible decoding**: routine JSON handles older fields such as string reps and legacy single-rest values.

## Project Structure

```text
IronFlow/
├── IronFlowApp.swift                  # App entry point
├── Theme/
│   ├── TokyoNightColors.swift         # TN.bg, TN.blue, TN.red, etc.
│   └── TerminalStyle.swift            # Shared fonts, button styles, card modifier
├── Models/
│   ├── Routine.swift                  # Routine -> Section -> ExerciseBlock
│   ├── SetRating.swift                # Fail / Good / Easy
│   └── WorkoutSession.swift           # Live workout state, timers, results, summaries, adjustments
├── Storage/
│   └── RoutineStore.swift             # JSON persistence, import/export, starter routines
└── Views/
    ├── RoutineListView.swift          # Home screen, import/export, routine selection
    ├── Workout/
    │   ├── WorkoutFlowView.swift      # Orchestrates exercise, timed work, rest, summary
    │   ├── ExerciseCardView.swift     # Rep-based exercise display, rating, swipe gesture
    │   ├── RestTimerView.swift        # Rest timer and timed exercise views
    │   ├── RoutineOverviewSheet.swift # Mid-workout full routine overview
    │   └── WorkoutSummaryView.swift   # End-of-workout report and clipboard copy
    └── Editor/
        ├── RoutineEditorView.swift    # Edit routine sections and exercises
        └── ExerciseEditorView.swift   # Edit individual exercise details
```

## Building & Deploying

Open `IronFlow.xcodeproj` in Xcode, select an iPhone destination, and run the app.

You can also build from the command line:

```bash
xcodebuild -project IronFlow.xcodeproj -scheme IronFlow \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

With a free Apple Developer account, a side-loaded app normally needs to be refreshed every 7 days. With a paid account, the signing period is longer.

## Starter Data

On first launch, IronFlow seeds the local JSON store with starter routines. These are just editable local data: change them in the app, import replacement JSON, or update `RoutineStore.swift`.

The README intentionally does not document the specific routine contents because those are personal training data and expected to change.
