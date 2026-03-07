import Foundation
import UserNotifications
import UIKit

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestPermissionIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                if granted {
                    await registerForRemoteNotifications()
                }
                return granted
            } catch {
                return false
            }
        case .authorized, .provisional:
            await registerForRemoteNotifications()
            return true
        default:
            return false
        }
    }

    @MainActor
    private func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }

    func registerDeviceToken(_ token: Data) {
        let tokenString = token.map { String(format: "%02x", $0) }.joined()

        Task {
            let body = DeviceTokenRequest(token: tokenString, platform: "ios")
            let _: DeviceTokenResponse? = try? await APIService.shared.post(
                endpoint: "/api/device-tokens",
                body: body
            )
        }
    }
}

struct DeviceTokenRequest: Encodable {
    let token: String
    let platform: String
}

struct DeviceTokenResponse: Decodable {
    let id: UUID
}
