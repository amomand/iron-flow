import SwiftUI

struct WorkoutFlowView: View {
    let routine: Routine
    let onDismiss: () -> Void
    @State private var session: WorkoutSession
    @State private var showQuitConfirm = false

    init(routine: Routine, onDismiss: @escaping () -> Void) {
        self.routine = routine
        self.onDismiss = onDismiss
        self._session = State(initialValue: WorkoutSession(routine: routine))
    }

    var body: some View {
        ZStack {
            TN.bg.ignoresSafeArea()

            if session.isFinished {
                WorkoutSummaryView(session: session, onDone: onDismiss)
            } else if session.isResting, let step = session.currentStep {
                RestTimerView(
                    seconds: step.exercise.restSeconds,
                    exerciseName: step.exercise.name,
                    onComplete: {
                        session.advanceToNextStep()
                    }
                )
                .id(session.currentStepIndex)
            } else if let step = session.currentStep {
                ExerciseCardView(
                    step: step,
                    totalSteps: session.steps.count,
                    currentIndex: session.currentStepIndex,
                    selectedRating: $session.selectedRating,
                    onComplete: {
                        session.completeCurrentSet()
                    },
                    onQuit: {
                        showQuitConfirm = true
                    }
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
    }
}
