import SwiftUI

@main
struct RayGarageApp: App {
    @StateObject private var store = GarageStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
