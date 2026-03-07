import Foundation
import SwiftUI

enum DayOfWeek: String, CaseIterable, Identifiable, Codable {
    case mon, tue, wed, thu, fri, sat, sun

    var id: String { rawValue }

    var shortLabel: String {
        switch self {
        case .mon: return "M"
        case .tue: return "T"
        case .wed: return "W"
        case .thu: return "T"
        case .fri: return "F"
        case .sat: return "S"
        case .sun: return "S"
        }
    }
}

struct HouseholdMember: Identifiable {
    let id: UUID
    let displayName: String
    let joinedAt: Date

    var joinedLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return "Joined \(formatter.string(from: joinedAt))"
    }
}

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var homeType: HomeType?
    @Published var roomCount = 0
    @Published var painPointCount = 0
    @Published var householdMembers: [HouseholdMember] = []
    @Published var inviteCode: String?
    @Published var showShareSheet = false
    @Published var joinCode = ""
    @Published var joinError: String?
    @Published var reminderEnabled = false
    @Published var reminderTime = defaultReminderTime()
    @Published var reminderDuration = 15
    @Published var reminderDays: Set<DayOfWeek> = [.mon, .tue, .wed, .thu, .fri]
    @Published var displayName = ""

    private var automationId: UUID?
    private var hasRequestedNotifications = false

    func load() async {
        await loadProfile()
        await loadHousehold()
        await loadAutomation()
    }

    // MARK: - Profile

    private func loadProfile() async {
        do {
            let response: MeResponse = try await APIService.shared.get(endpoint: "/api/me")
            displayName = response.user.firstName ?? ""
        } catch {}
    }

    func updateDisplayName() async {
        let body = UpdateProfileRequest(firstName: displayName)
        let _: User? = try? await APIService.shared.patch(endpoint: "/api/me", body: body)
    }

    // MARK: - Household

    private func loadHousehold() async {
        do {
            let response: HouseholdDetailResponse = try await APIService.shared.get(
                endpoint: "/api/households/me"
            )
            roomCount = response.rooms?.count ?? 0
            painPointCount = response.painPoints?.count ?? 0
            inviteCode = response.household.inviteCode
            householdMembers = (response.members ?? []).map {
                HouseholdMember(id: $0.id, displayName: $0.displayName ?? "Member", joinedAt: $0.joinedAt)
            }
        } catch {}
    }

    func generateInviteCode() async {
        do {
            let response: InviteCodeResponse = try await APIService.shared.post(
                endpoint: "/api/households/invite"
            )
            inviteCode = response.code
        } catch {}
    }

    func copyInviteCode() {
        guard let code = inviteCode else { return }
        UIPasteboard.general.string = code
    }

    func joinHousehold() async {
        let code = joinCode.trimmingCharacters(in: .whitespaces)
        guard !code.isEmpty else { return }
        joinError = nil

        do {
            let body = JoinHouseholdRequest(code: code)
            let _: JoinHouseholdResponse = try await APIService.shared.post(
                endpoint: "/api/households/join",
                body: body
            )
            joinCode = ""
            await loadHousehold()
        } catch {
            joinError = "Invalid code or couldn't join."
        }
    }

    // MARK: - Automation

    private func loadAutomation() async {
        do {
            let response: AutomationListResponse = try await APIService.shared.get(
                endpoint: "/api/automations"
            )
            if let automation = response.automations.first {
                automationId = automation.id
                reminderEnabled = automation.isEnabled
                if let config = automation.config {
                    reminderTime = timeFromString(config.timeOfDay) ?? SettingsViewModel.defaultReminderTime()
                    reminderDuration = config.durationMinutes
                    reminderDays = Set(config.days)
                }
            }
        } catch {}
    }

    func onReminderEnabled() async {
        if !hasRequestedNotifications {
            hasRequestedNotifications = true
            _ = await NotificationService.shared.requestPermissionIfNeeded()
        }
        await saveAutomation()
    }

    func saveAutomation() async {
        let config = AutomationConfig(
            timeOfDay: timeToString(reminderTime),
            durationMinutes: reminderDuration,
            days: Array(reminderDays)
        )
        let body = SaveAutomationRequest(
            isEnabled: reminderEnabled,
            config: config
        )

        if let automationId {
            let _: Automation? = try? await APIService.shared.patch(
                endpoint: "/api/automations/\(automationId.uuidString)",
                body: body
            )
        } else {
            if let response: Automation = try? await APIService.shared.post(
                endpoint: "/api/automations",
                body: body
            ) {
                automationId = response.id
            }
        }
    }

    func toggleDay(_ day: DayOfWeek) {
        if reminderDays.contains(day) {
            if reminderDays.count > 1 {
                reminderDays.remove(day)
            }
        } else {
            reminderDays.insert(day)
        }
    }

    // MARK: - Time Helpers

    private static func defaultReminderTime() -> Date {
        var components = DateComponents()
        components.hour = 16
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    private func timeToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func timeFromString(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: string)
    }
}

// MARK: - API Types

struct UpdateProfileRequest: Encodable {
    let firstName: String
}

struct HouseholdDetailResponse: Decodable {
    let household: HouseholdDetail
    let members: [MemberDetail]?
    let rooms: [Room]?
    let painPoints: [PainPoint]?
}

struct HouseholdDetail: Decodable {
    let id: UUID
    let name: String
    let inviteCode: String?
}

struct MemberDetail: Decodable, Identifiable {
    let id: UUID
    let displayName: String?
    let joinedAt: Date
}

struct InviteCodeResponse: Decodable {
    let code: String
}

struct JoinHouseholdRequest: Encodable {
    let code: String
}

struct JoinHouseholdResponse: Decodable {
    let householdId: UUID
}

struct AutomationConfig: Codable {
    let timeOfDay: String
    let durationMinutes: Int
    let days: [DayOfWeek]
}

struct AutomationListResponse: Decodable {
    let automations: [AutomationDetail]
}

struct AutomationDetail: Decodable, Identifiable {
    let id: UUID
    let isEnabled: Bool
    let config: AutomationConfig?
}

struct SaveAutomationRequest: Encodable {
    let isEnabled: Bool
    let config: AutomationConfig
}
