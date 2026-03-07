import Foundation

struct Household: Codable, Identifiable {
    let id: UUID
    let name: String
    let createdAt: Date
    let updatedAt: Date
}
