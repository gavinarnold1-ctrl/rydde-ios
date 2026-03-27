import SwiftUI

@main
struct RyddeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authService = AuthService.shared
    @State private var deepLinkDuration: Int?
    @State private var deepLinkAction: DeepLinkAction?

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authService)
                .environment(\.deepLinkDuration, $deepLinkDuration)
                .environment(\.deepLinkAction, $deepLinkAction)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "rydde" else { return }

        switch url.host {
        case "clean":
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if let durationStr = components?.queryItems?.first(where: { $0.name == "duration" })?.value,
               let duration = Int(durationStr) {
                deepLinkDuration = duration
            } else {
                deepLinkDuration = 15
            }

        case "done":
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if let sessionIdStr = components?.queryItems?.first(where: { $0.name == "sessionId" })?.value,
               let sessionId = UUID(uuidString: sessionIdStr) {
                deepLinkAction = .done(sessionId: sessionId)
            }

        case "skip":
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if let sessionIdStr = components?.queryItems?.first(where: { $0.name == "sessionId" })?.value,
               let sessionId = UUID(uuidString: sessionIdStr) {
                deepLinkAction = .skip(sessionId: sessionId)
            }

        default:
            break
        }
    }
}

// MARK: - Deep Link Types

enum DeepLinkAction: Equatable {
    case done(sessionId: UUID)
    case skip(sessionId: UUID)
}

// MARK: - Environment Keys

private struct DeepLinkDurationKey: EnvironmentKey {
    static let defaultValue: Binding<Int?> = .constant(nil)
}

private struct DeepLinkActionKey: EnvironmentKey {
    static let defaultValue: Binding<DeepLinkAction?> = .constant(nil)
}

extension EnvironmentValues {
    var deepLinkDuration: Binding<Int?> {
        get { self[DeepLinkDurationKey.self] }
        set { self[DeepLinkDurationKey.self] = newValue }
    }

    var deepLinkAction: Binding<DeepLinkAction?> {
        get { self[DeepLinkActionKey.self] }
        set { self[DeepLinkActionKey.self] = newValue }
    }
}
