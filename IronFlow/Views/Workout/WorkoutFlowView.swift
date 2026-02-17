import SwiftUI

struct WorkoutFlowView: View {
    let routine: Routine
    let store: RoutineStore
    let onDismiss: () -> Void
    @State private var session: WorkoutSession
    @State private var showQuitConfirm = false
    @State private var showOverview = false

    init(routine: Routine, store: RoutineStore, onDismiss: @escaping () -> Void) {
        self.routine = routine
        self.store = store
        self.onDismiss = onDismiss
        self._session = State(initialValue: WorkoutSession(routine: routine))
    }

    var body: some View {
        ZStack {
            TN.bg.ignoresSafeArea()

            if session.isFinished {
                WorkoutSummaryView(session: session, store: store, onDone: onDismiss)
            } else if session.isResting, let step = session.currentStep {
                RestTimerView(
                    seconds: step.restSeconds,
                    nextExerciseName: session.nextStep?.exercise.name ?? "done!",
                    estimatedMinutes: session.estimatedMinutesRemaining,
                    onComplete: {
                        session.advanceToNextStep()
                    },
                    onShowOverview: { showOverview = true }
                )
                .id(session.currentStepIndex)
            } else if let step = session.currentStep {
                ExerciseCardView(
                    step: step,
                    totalSteps: session.steps.count,
                    currentIndex: session.currentStepIndex,
                    estimatedMinutes: session.estimatedMinutesRemaining,
                    selectedRating: $session.selectedRating,
                    onComplete: {
                        session.completeCurrentSet()
                    },
                    onQuit: {
                        showQuitConfirm = true
                    },
                    onShowOverview: { showOverview = true }
                )
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .alert("Quit Workout?", isPresented: $showQuitConfirm) {
            Button("Keep Going", role: .cancel) { }
            Button("Quit", role: .destructive) { onDismiss() }
        } message: {
            Text("Progress will be lost.")
        }
        .sheet(isPresented: $showOverview) {
            RoutineOverviewSheet(session: session)
        }
    }
}
