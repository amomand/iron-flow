import SwiftUI

struct ExerciseEditorView: View {
    @State private var exercise: ExerciseBlock
    @State private var isNew: Bool
    let onSave: (ExerciseBlock) -> Void
    @Environment(\.dismiss) private var dismiss

    init(exercise: ExerciseBlock?, onSave: @escaping (ExerciseBlock) -> Void) {
        if let exercise {
            self._exercise = State(initialValue: exercise)
            self._isNew = State(initialValue: false)
        } else {
            self._exercise = State(initialValue: ExerciseBlock(name: ""))
            self._isNew = State(initialValue: true)
        }
        self.onSave = onSave
    }

    var body: some View {
        ZStack {
            TN.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    editorField("NAME", text: $exercise.name)

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SETS")
                                .terminalFont(11)
                                .foregroundColor(TN.comment)
                            HStack(spacing: 12) {
                                Button {
                                    if exercise.sets > 1 { exercise.sets -= 1 }
                                } label: {
                                    Text("−")
                                        .terminalFont(18, weight: .bold)
                                        .foregroundColor(TN.red)
                                        .frame(width: 36, height: 36)
                                        .background(TN.darkCard)
                                        .cornerRadius(4)
                                }
                                Text("\(exercise.sets)")
                                    .terminalFont(22, weight: .bold)
                                    .foregroundColor(TN.fg)
                                    .frame(minWidth: 30)
                                Button {
                                    exercise.sets += 1
                                } label: {
                                    Text("+")
                                        .terminalFont(18, weight: .bold)
                                        .foregroundColor(TN.green)
                                        .frame(width: 36, height: 36)
                                        .background(TN.darkCard)
                                        .cornerRadius(4)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("REPS")
                                .terminalFont(11)
                                .foregroundColor(TN.comment)
                            TextField("e.g. 8-10", text: $exercise.reps)
                                .terminalFont(16)
                                .foregroundColor(TN.fg)
                                .textFieldStyle(.plain)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(TN.darkCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(TN.comment.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    }

                    // Rest
                    VStack(alignment: .leading, spacing: 4) {
                        Text("REST (SECONDS)")
                            .terminalFont(11)
                            .foregroundColor(TN.comment)

                        HStack(spacing: 8) {
                            ForEach([0, 15, 30, 45, 60, 90, 120], id: \.self) { sec in
                                Button {
                                    exercise.restSeconds = sec
                                } label: {
                                    Text(sec == 0 ? "—" : "\(sec)")
                                        .terminalFont(13, weight: .bold)
                                        .foregroundColor(exercise.restSeconds == sec ? TN.bg : TN.fg)
                                        .frame(minWidth: 36, minHeight: 36)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(exercise.restSeconds == sec ? TN.blue : TN.darkCard)
                                        )
                                }
                            }
                        }
                    }

                    // Per side toggle
                    Toggle(isOn: $exercise.perSide) {
                        Text("Each side")
                            .terminalFont(14)
                            .foregroundColor(TN.fg)
                    }
                    .tint(TN.blue)

                    // Notes
                    VStack(alignment: .leading, spacing: 4) {
                        Text("NOTES")
                            .terminalFont(11)
                            .foregroundColor(TN.comment)
                        TextField("Optional notes...", text: $exercise.notes, axis: .vertical)
                            .terminalFont(14)
                            .foregroundColor(TN.fg)
                            .textFieldStyle(.plain)
                            .lineLimit(3...6)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(TN.darkCard)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(TN.comment.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
                .padding()
            }
        }
        .navigationTitle(isNew ? "New Exercise" : "Edit Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(TN.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .foregroundColor(TN.comment)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave(exercise)
                    dismiss()
                }
                .foregroundColor(TN.blue)
                .bold()
                .disabled(exercise.name.isEmpty)
            }
        }
    }

    private func editorField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .terminalFont(11)
                .foregroundColor(TN.comment)
            TextField("", text: text)
                .terminalFont(16, weight: .bold)
                .foregroundColor(TN.fg)
                .textFieldStyle(.plain)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(TN.darkCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(TN.comment.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }
}
