import SwiftUI
import SwiftData

@main
struct PowerCANLiquidVisionApp: App {
    @StateObject private var viewModel = OBDViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: TripRecord.self)
    }
}
