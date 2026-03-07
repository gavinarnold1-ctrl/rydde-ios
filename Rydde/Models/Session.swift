import Foundation

struct Session: Codable, Identifiable {
    let id: UUID
    let householdId: UUID
    let userId: UUID
    let roomId: UUID?
    let status: String
    let startedAt: Date?
    let completedAt: Date?
    let durationMinutes: Int?
    let createdAt: Date
    let updatedAt: Date
}
