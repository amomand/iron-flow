import SwiftUI

@main
struct IronFlowApp: App {
    @State private var store = RoutineStore()

    var body: some Scene {
        WindowGroup {
            RoutineListView(store: store)
                .preferredColorScheme(.dark)
        }
    }
}
