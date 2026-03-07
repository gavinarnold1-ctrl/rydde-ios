import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let appleUserId: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let householdId: UUID?
    let role: String?
    let createdAt: Date
    let updatedAt: Date
}
