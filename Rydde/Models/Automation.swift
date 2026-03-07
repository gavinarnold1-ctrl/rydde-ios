import Foundation

struct Automation: Codable, Identifiable {
    let id: UUID
    let householdId: UUID
    let name: String
    let description: String?
    let triggerType: String?
    let triggerConfig: String?
    let actionType: String?
    let actionConfig: String?
    let isEnabled: Bool
    let createdAt: Date
    let updatedAt: Date
}
