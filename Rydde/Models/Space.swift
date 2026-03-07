import Foundation

struct Space: Codable, Identifiable {
    let id: UUID
    let householdId: UUID
    let name: String
    let description: String?
    let createdAt: Date
    let updatedAt: Date
}
