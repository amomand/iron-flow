import SwiftUI

struct RoutineListView: View {
    @Bindable var store: RoutineStore
    @State private var selectedRoutine: Routine?
    @State private var editingRoutine: Routine?
    @State private var showingNewRoutine = false

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
                WorkoutFlowView(routine: routine) {
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
