import SwiftUI

struct RoutineListView: View {
    @Bindable var store: RoutineStore
    @State private var selectedRoutine: Routine?
    @State private var editingRoutine: Routine?
    @State private var showingNewRoutine = false
    @State private var showingImport = false
    @State private var exportedJSON: String?
    @State private var showExportCopied = false

    var body: some View {
        NavigationStack {
            ZStack {
                TN.bg.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Text("// IRONFLOW")
                            .terminalFont(22, weight: .bold)
                            .foregroundColor(TN.blue)
                        Spacer()
                        Button {
                            showingImport = true
                        } label: {
                            Text("[ ↓ IMPORT ]")
                        }
                        .buttonStyle(TerminalButtonStyle(color: TN.purple))
                        Button {
                            showingNewRoutine = true
                        } label: {
                            Text("[ + NEW ]")
                        }
                        .buttonStyle(TerminalButtonStyle(color: TN.green))
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    Text("select routine to begin")
                        .terminalFont(13)
                        .foregroundColor(TN.comment)
                        .padding(.horizontal)
                        .padding(.top, 4)

                    Divider()
                        .background(TN.comment.opacity(0.3))
                        .padding(.vertical, 12)

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(store.routines) { routine in
                                RoutineRow(routine: routine)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedRoutine = routine
                                    }
                                    .contextMenu {
                                        Button("Edit") {
                                            editingRoutine = routine
                                        }
                                        Button("Export JSON") {
                                            if let json = store.exportRoutineJSON(routine) {
                                                UIPasteboard.general.string = json
                                                showExportCopied = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    showExportCopied = false
                                                }
                                            }
                                        }
                                        Button("Delete", role: .destructive) {
                                            if let idx = store.routines.firstIndex(where: { $0.id == routine.id }) {
                                                store.deleteRoutine(at: IndexSet(integer: idx))
                                            }
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedRoutine) { routine in
                WorkoutFlowView(routine: routine, store: store) {
                    selectedRoutine = nil
                }
            }
            .sheet(item: $editingRoutine) { routine in
                NavigationStack {
                    RoutineEditorView(store: store, routine: routine)
                }
            }
            .sheet(isPresented: $showingNewRoutine) {
                NavigationStack {
                    RoutineEditorView(store: store, routine: nil)
                }
            }
            .sheet(isPresented: $showingImport) {
                ImportRoutineSheet(store: store)
            }
            .overlay {
                if showExportCopied {
                    Text("[ ✓ JSON COPIED ]")
                        .terminalFont(14, weight: .bold)
                        .foregroundColor(TN.green)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(TN.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(TN.green.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .transition(.opacity)
                        .animation(.easeInOut, value: showExportCopied)
                }
            }
        }
    }
}

struct RoutineRow: View {
    let routine: Routine

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(routine.name)
                .terminalFont(16, weight: .bold)
                .foregroundColor(TN.fg)

            HStack(spacing: 16) {
                let exerciseCount = routine.sections.flatMap(\.exercises).count
                let setCount = routine.sections.flatMap(\.exercises).map(\.sets).reduce(0, +)
                Label("\(routine.sections.count) blocks", systemImage: "list.bullet")
                Label("\(exerciseCount) exercises", systemImage: "figure.strengthtraining.traditional")
                Label("\(setCount) sets", systemImage: "repeat")
            }
            .terminalFont(12)
            .foregroundColor(TN.comment)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .terminalCard()
    }
}

struct ImportRoutineSheet: View {
    let store: RoutineStore
    @Environment(\.dismiss) private var dismiss
    @State private var jsonText = ""
    @State private var errorMessage: String?
    @State private var importedName: String?

    var body: some View {
        ZStack {
            TN.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("// IMPORT ROUTINE")
                        .terminalFont(16, weight: .bold)
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

                Text("Paste routine JSON below, or paste from clipboard.")
                    .terminalFont(12)
                    .foregroundColor(TN.comment)

                Button {
                    if let clip = UIPasteboard.general.string {
                        jsonText = clip
                    }
                } label: {
                    Text("[ PASTE FROM CLIPBOARD ]")
                }
                .buttonStyle(TerminalButtonStyle(color: TN.blue))

                TextEditor(text: $jsonText)
                    .terminalFont(12)
                    .foregroundColor(TN.fg)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(TN.darkCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(TN.comment.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .frame(minHeight: 200)

                if let error = errorMessage {
                    Text(error)
                        .terminalFont(12)
                        .foregroundColor(TN.red)
                }

                if let name = importedName {
                    Text("✅ Imported: \(name)")
                        .terminalFont(13, weight: .bold)
                        .foregroundColor(TN.green)
                }

                HStack {
                    Spacer()
                    Button {
                        errorMessage = nil
                        importedName = nil
                        let result = store.importRoutineFromJSON(jsonText)
                        switch result {
                        case .success(let routine):
                            importedName = routine.name
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                dismiss()
                            }
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                        }
                    } label: {
                        Text("[ IMPORT ]")
                    }
                    .buttonStyle(TerminalButtonStyle(color: TN.green))
                    .disabled(jsonText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding()
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
