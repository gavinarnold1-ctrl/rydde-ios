import Foundation

struct RyddeTask: Codable, Identifiable {
    let id: UUID
    let sessionId: UUID
    let title: String
    let description: String?
    let status: String
    let sortOrder: Int?
    let completedAt: Date?
    let createdAt: Date
    let updatedAt: Date
}
