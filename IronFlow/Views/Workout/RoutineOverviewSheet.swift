import SwiftUI

struct RoutineOverviewSheet: View {
    let session: WorkoutSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            TN.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("// ROUTINE OVERVIEW")
                        .terminalFont(14, weight: .bold)
                        .foregroundColor(TN.purple)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Text("[ ✕ ]")
                            .terminalFont(14, weight: .bold)
                            .foregroundColor(TN.comment)
                    }
                }
                .padding()

                Divider()
                    .background(TN.comment.opacity(0.3))

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        var lastSection = ""

                        ForEach(Array(session.steps.enumerated()), id: \.element.id) { index, step in
                            let isNewSection = step.sectionName != lastSection

                            // Section header
                            if isNewSection {
                                let _ = (lastSection = step.sectionName)
                                Text("// \(step.sectionName.uppercased())")
                                    .terminalFont(12, weight: .bold)
                                    .foregroundColor(TN.purple)
                                    .padding(.horizontal)
                                    .padding(.top, 16)
                                    .padding(.bottom, 4)
                            }

                            OverviewStepRow(
                                step: step,
                                index: index,
                                currentIndex: session.currentStepIndex
                            )
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

struct OverviewStepRow: View {
    let step: WorkoutStep
    let index: Int
    let currentIndex: Int

    private var isCompleted: Bool { index < currentIndex }
    private var isCurrent: Bool { index == currentIndex }

    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            if isCompleted {
                Image(systemName: "checkmark")
                    .foregroundColor(TN.green.opacity(0.5))
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .frame(width: 20)
            } else if isCurrent {
                Image(systemName: "chevron.right")
                    .foregroundColor(TN.blue)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .frame(width: 20)
            } else {
                Color.clear.frame(width: 20, height: 1)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(step.exercise.name)
                    .terminalFont(13, weight: isCurrent ? .bold : .regular)
                    .foregroundColor(isCompleted ? TN.comment.opacity(0.5) : (isCurrent ? TN.fg : TN.fg))
                    .strikethrough(isCompleted)

                HStack(spacing: 8) {
                    Text("Set \(step.setNumber)/\(step.exercise.sets)")
                        .terminalFont(11)
                        .foregroundColor(isCompleted ? TN.comment.opacity(0.3) : TN.comment)
                    Text("× \(step.exercise.reps) reps")
                        .terminalFont(11)
                        .foregroundColor(isCompleted ? TN.comment.opacity(0.3) : TN.comment)
                    if step.exercise.perSide {
                        Text("↔")
                            .terminalFont(11)
                            .foregroundColor(isCompleted ? TN.orange.opacity(0.3) : TN.orange)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(isCurrent ? TN.card : Color.clear)
    }
}
