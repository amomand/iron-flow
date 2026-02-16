import SwiftUI

struct RestTimerView: View {
    let seconds: Int
    let exerciseName: String
    let onComplete: () -> Void
    let onSkip: () -> Void

    @State private var remaining: Int
    @State private var timer: Timer?
    @State private var hasHapticFired = false
    @State private var hasCompleted = false

    init(seconds: Int, exerciseName: String, onComplete: @escaping () -> Void, onSkip: @escaping () -> Void) {
        self.seconds = seconds
        self.exerciseName = exerciseName
        self.onComplete = onComplete
        self.onSkip = onSkip
        self._remaining = State(initialValue: seconds)
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("// REST")
                .terminalFont(14)
                .foregroundColor(TN.purple)

            Text(timeString)
                .terminalFont(72, weight: .bold)
                .foregroundColor(remaining <= 5 ? TN.red : TN.blue)
                .shadow(color: (remaining <= 5 ? TN.red : TN.blue).opacity(0.4), radius: 20)
                .contentTransition(.numericText())
                .animation(.linear(duration: 0.1), value: remaining)

            // Progress ring
            ZStack {
                Circle()
                    .stroke(TN.darkCard, lineWidth: 4)
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0, to: seconds > 0 ? CGFloat(remaining) / CGFloat(seconds) : 0)
                    .stroke(remaining <= 5 ? TN.red : TN.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: remaining)
            }

            Text("after: \(exerciseName)")
                .terminalFont(13)
                .foregroundColor(TN.comment)

            Spacer()

            Button {
                guard !hasCompleted else { return }
                hasCompleted = true
                stopTimer()
                onSkip()
            } label: {
                Text("[ SKIP ▸ ]")
            }
            .buttonStyle(TerminalButtonStyle(color: TN.comment))
            .padding(.bottom, 40)
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }

    private var timeString: String {
        let m = remaining / 60
        let s = remaining % 60
        return String(format: "%d:%02d", m, s)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remaining > 0 {
                remaining -= 1
                if remaining == 0 && !hasCompleted {
                    hasCompleted = true
                    fireHaptic()
                    stopTimer()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onComplete()
                    }
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func fireHaptic() {
        guard !hasHapticFired else { return }
        hasHapticFired = true
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        // Fire a second burst after a short delay for emphasis
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        }
    }
}
