import SwiftUI

struct RestTimerView: View {
    let seconds: Int
    let remaining: Int
    let nextExerciseName: String
    let estimatedMinutes: Int
    let onSkip: () -> Void
    let onShowOverview: () -> Void

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
                onSkip()
            } label: {
                Text("[ SKIP ▸ ]")
            }
            .buttonStyle(TerminalButtonStyle(color: TN.comment))
            .padding(.bottom, 40)
        }
    }

    private var timeString: String {
        let m = remaining / 60
        let s = remaining % 60
        return String(format: "%d:%02d", m, s)
    }
}

struct TimedExerciseView: View {
    let step: WorkoutStep
    let totalSteps: Int
    let currentIndex: Int
    let estimatedMinutes: Int
    let seconds: Int
    let remaining: Int
    let nextLabel: String
    let onSkip: () -> Void
    let onQuit: () -> Void
    let onShowOverview: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    onQuit()
                } label: {
                    Text("[ ✕ ]")
                        .terminalFont(14, weight: .bold)
                        .foregroundColor(TN.comment)
                }

                Spacer()

                Text("~\(estimatedMinutes) min left")
                    .terminalFont(12)
                    .foregroundColor(TN.comment)

                Spacer()

                HStack(spacing: 12) {
                    Button {
                        onShowOverview()
                    } label: {
                        Image(systemName: "list.bullet")
                            .foregroundColor(TN.comment)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                    }

                    Text("\(currentIndex + 1)/\(totalSteps)")
                        .terminalFont(13)
                        .foregroundColor(TN.comment)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(TN.darkCard)
                        .frame(height: 3)
                    Rectangle()
                        .fill(TN.green)
                        .frame(width: geo.size.width * Double(currentIndex) / Double(max(totalSteps, 1)), height: 3)
                }
            }
            .frame(height: 3)
            .padding(.horizontal)
            .padding(.top, 8)

            Spacer()

            if step.isFirstInSection {
                Text("// \(step.sectionName.uppercased())")
                    .terminalFont(13)
                    .foregroundColor(TN.purple)
                    .padding(.bottom, 8)
            }

            VStack(spacing: 20) {
                Text(step.exercise.name.uppercased())
                    .terminalFont(22, weight: .bold)
                    .foregroundColor(TN.fg)
                    .multilineTextAlignment(.center)

                HStack(spacing: 24) {
                    VStack(spacing: 4) {
                        Text("SET")
                            .terminalFont(11)
                            .foregroundColor(TN.comment)
                        Text("\(step.setNumber) of \(step.exercise.sets)")
                            .terminalFont(18, weight: .bold)
                            .foregroundColor(TN.blue)
                    }

                    Rectangle()
                        .fill(TN.comment.opacity(0.3))
                        .frame(width: 1, height: 30)

                    VStack(spacing: 4) {
                        Text("TIME")
                            .terminalFont(11)
                            .foregroundColor(TN.comment)
                        Text(timeString)
                            .terminalFont(18, weight: .bold)
                            .foregroundColor(remaining <= 5 ? TN.red : TN.green)
                    }
                }

                ZStack {
                    Circle()
                        .stroke(TN.darkCard, lineWidth: 4)
                        .frame(width: 120, height: 120)
                    Circle()
                        .trim(from: 0, to: seconds > 0 ? CGFloat(remaining) / CGFloat(seconds) : 0)
                        .stroke(remaining <= 5 ? TN.red : TN.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: remaining)
                }

                Text("next: \(nextLabel)")
                    .terminalFont(13)
                    .foregroundColor(TN.comment)

                if step.exercise.perSide {
                    Text("↔ EACH SIDE")
                        .terminalFont(12, weight: .bold)
                        .foregroundColor(TN.orange)
                }

                if !step.exercise.notes.isEmpty {
                    Divider()
                        .background(TN.comment.opacity(0.3))
                    Text(step.exercise.notes)
                        .terminalFont(13)
                        .foregroundColor(TN.comment)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(24)
            .terminalCard()
            .padding(.horizontal, 20)

            Spacer()

            Text("auto-advances at zero")
                .terminalFont(12)
                .foregroundColor(TN.comment.opacity(0.5))
                .padding(.bottom, 12)

            Button {
                onSkip()
            } label: {
                Text("[ SKIP ▸ ]")
            }
            .buttonStyle(TerminalButtonStyle(color: TN.comment))
            .padding(.bottom, 40)
        }
    }

    private var timeString: String {
        let m = remaining / 60
        let s = remaining % 60
        return String(format: "%d:%02d", m, s)
    }
}
