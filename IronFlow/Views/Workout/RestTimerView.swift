import SwiftUI

struct RestTimerView: View {
    let seconds: Int
    let nextExerciseName: String
    let estimatedMinutes: Int
    let onComplete: () -> Void
    let onShowOverview: () -> Void

    @State private var remaining: Int
    @State private var timer: Timer?
    @State private var hasCompleted = false
    @State private var endTime: Date = .now

    init(seconds: Int, nextExerciseName: String, estimatedMinutes: Int, onComplete: @escaping () -> Void, onShowOverview: @escaping () -> Void) {
        self.seconds = seconds
        self.nextExerciseName = nextExerciseName
        self.estimatedMinutes = estimatedMinutes
        self.onComplete = onComplete
        self.onShowOverview = onShowOverview
        self._remaining = State(initialValue: seconds)
    }

    var body: some View {
        VStack(spacing: 32) {
            // Top bar with overview button and time remaining
            HStack {
                Spacer()
                Text("~\(estimatedMinutes) min left")
                    .terminalFont(12)
                    .foregroundColor(TN.comment)
                Spacer()
                Button {
                    onShowOverview()
                } label: {
                    Image(systemName: "list.bullet")
                        .foregroundColor(TN.comment)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

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

            Text("next: \(nextExerciseName)")
                .terminalFont(13)
                .foregroundColor(TN.comment)

            Spacer()

            Button {
                guard !hasCompleted else { return }
                hasCompleted = true
                stopTimer()
                fireHaptic()
                onComplete()
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
        endTime = Date().addingTimeInterval(Double(seconds))
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            let rem = Int(endTime.timeIntervalSinceNow.rounded(.up))
            if rem > 0 {
                remaining = rem
            } else if !hasCompleted {
                remaining = 0
                hasCompleted = true
                fireHaptic()
                stopTimer()
                onComplete()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func fireHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
