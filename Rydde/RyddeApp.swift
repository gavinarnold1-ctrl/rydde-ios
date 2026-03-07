import SwiftUI

@main
struct RyddeApp: App {
    @StateObject private var authService = AuthService.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authService)
        }
    }
}
