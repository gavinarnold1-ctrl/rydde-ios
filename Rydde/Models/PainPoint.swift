import Foundation

struct PainPoint: Codable, Identifiable {
    let id: UUID
    let householdId: UUID
    let roomId: UUID?
    let description: String
    let severity: Int?
    let createdAt: Date
    let updatedAt: Date
}
