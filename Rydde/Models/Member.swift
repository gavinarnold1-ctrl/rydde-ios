import Foundation

struct Member: Codable, Identifiable {
    let id: UUID
    let householdId: UUID
    let userId: UUID
    let role: String
    let createdAt: Date
    let updatedAt: Date
}
