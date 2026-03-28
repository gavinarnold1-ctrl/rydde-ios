import Foundation
import SwiftUI

enum AppearanceMode: String, CaseIterable {
    case light, dark, system

    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

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
    @Published var roomNames: [String] = []
    @Published var painPointItems: [PainPointItem] = []
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
    @Published var showEditHome = false
    @Published var showEditRooms = false
    @Published var showEditPainPoints = false
    @Published var showSupplies = false
    @Published var appearanceMode: AppearanceMode = {
        let raw = UserDefaults.standard.string(forKey: "appearanceMode") ?? "light"
        return AppearanceMode(rawValue: raw) ?? .light
    }()

    private var automationId: UUID?
    private var spaceId: UUID?
    private var householdId: UUID?
    private var hasRequestedNotifications = false

    func load() async {
        await loadProfile()
        await loadHousehold()
        await loadAutomation()
    }

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

    private func loadHousehold() async {
        do {
            let response: HouseholdDetailResponse = try await APIService.shared.get(endpoint: "/api/households/me")
            householdId = response.household.id
            roomCount = response.rooms?.count ?? 0
            painPointCount = response.painPoints?.count ?? 0
            inviteCode = response.household.inviteCode
            roomNames = (response.rooms ?? []).map { $0.name }
            painPointItems = (response.painPoints ?? []).map { PainPointItem(id: $0.id, description: $0.description) }
            householdMembers = (response.members ?? []).map {
                HouseholdMember(id: $0.id, displayName: $0.displayName ?? "Member", joinedAt: $0.joinedAt)
            }
            let spacesResponse: SpacesListResponse? = try? await APIService.shared.get(endpoint: "/api/spaces")
            if let space = spacesResponse?.spaces.first {
                spaceId = space.id
                homeType = HomeType(rawValue: space.name.lowercased())
            }
        } catch {}
    }

    func generateInviteCode() async {
        do {
            let response: InviteCodeResponse = try await APIService.shared.post(endpoint: "/api/households/invite")
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
            let _: JoinHouseholdResponse = try await APIService.shared.post(endpoint: "/api/households/join", body: body)
            joinCode = ""
            await loadHousehold()
        } catch {
            joinError = "Invalid code or couldn't join."
        }
    }

    func updateHomeType(_ type: HomeType) async {
        guard let spaceId else { return }
        let body = UpdateSpaceRequest(id: spaceId, name: type.rawValue)
        let _: UpdateSpaceResponse? = try? await APIService.shared.put(endpoint: "/api/spaces", body: body)
        homeType = type
    }

    func updateRooms(_ rooms: [String]) async {
        guard let spaceId else { return }
        let body = UpdateSpaceRequest(id: spaceId, rooms: rooms)
        let _: UpdateSpaceResponse? = try? await APIService.shared.put(endpoint: "/api/spaces", body: body)
        roomNames = rooms
        roomCount = rooms.count
    }

    func addPainPoints(_ descriptions: [String]) async {
        guard let householdId else { return }
        let body = CreatePainPointsRequest(householdId: householdId, descriptions: descriptions)
        let _: CreatePainPointsResponse? = try? await APIService.shared.post(endpoint: "/api/pain-points", body: body)
        painPointCount += descriptions.count
    }

    func deletePainPoint(_ id: UUID) async {
        struct DeleteResponse: Decodable { let deleted: Bool }
        let _: DeleteResponse? = try? await APIService.shared.delete(endpoint: "/api/pain-points?id=\(id.uuidString)")
        painPointCount = max(0, painPointCount - 1)
    }

    private var isLoadingAutomation = false

    private func loadAutomation() async {
        isLoadingAutomation = true
        defer { isLoadingAutomation = false }
        do {
            let response: AutomationListResponse = try await APIService.shared.get(endpoint: "/api/automations")
            if let automation = response.automations.first {
                automationId = automation.id
                reminderEnabled = automation.isEnabled
                if let config = automation.config {
                    reminderTime = timeFromString(config.timeOfDay) ?? SettingsViewModel.defaultReminderTime()
                    reminderDuration = config.durationMinutes
                    reminderDays = Set(config.days)
                }
            }
        } catch {
            print("loadAutomation failed: \(error)")
        }
    }

    func onReminderEnabled() async {
        if !hasRequestedNotifications {
            hasRequestedNotifications = true
            _ = await NotificationService.shared.requestPermissionIfNeeded()
        }
        await saveAutomation()
    }

    func saveAutomation() async {
        guard !isLoadingAutomation else { return } // Don't save while loading
        let config = AutomationConfig(timeOfDay: timeToString(reminderTime), durationMinutes: reminderDuration, days: Array(reminderDays))
        let body = SaveAutomationRequest(isEnabled: reminderEnabled, config: config)
        do {
            if let automationId {
                let response: AutomationDetail = try await APIService.shared.patch(endpoint: "/api/automations/\(automationId.uuidString)", body: body)
                reminderEnabled = response.isEnabled
            } else {
                let response: AutomationDetail = try await APIService.shared.post(endpoint: "/api/automations", body: body)
                automationId = response.id
                reminderEnabled = response.isEnabled
            }
        } catch {
            print("saveAutomation failed: \(error)")
        }
    }

    func toggleDay(_ day: DayOfWeek) {
        if reminderDays.contains(day) {
            if reminderDays.count > 1 { reminderDays.remove(day) }
        } else {
            reminderDays.insert(day)
        }
    }

    func saveAppearance(_ mode: AppearanceMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: "appearanceMode")
    }

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

// MARK: - API Types (no duplicates with OnboardingFlow)

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

struct SpacesListResponse: Decodable {
    let spaces: [SpaceDetail]
}

struct SpaceDetail: Decodable, Identifiable {
    let id: UUID
    let name: String
}

struct UpdateSpaceRequest: Encodable {
    let id: UUID
    var name: String?
    var rooms: [String]?
}

struct UpdateSpaceResponse: Decodable {
    let space: SpaceDetail
}
