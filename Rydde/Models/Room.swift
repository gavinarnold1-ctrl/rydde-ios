import Foundation

struct Room: Codable, Identifiable {
    let id: UUID
    let spaceId: UUID
    let name: String
    let description: String?
    let createdAt: Date
    let updatedAt: Date
}
