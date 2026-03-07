import Foundation

struct TaskEntry: Codable, Identifiable {
    let id: UUID
    let sessionId: UUID
    let room: String
    let roomId: UUID?
    let title: String
    let status: String
    let durationMinutes: Int?
    let completedAt: Date?
    let createdAt: Date

    var isSkipped: Bool { status == "skipped" }
}

struct TaskListResponse: Codable {
    let tasks: [TaskEntry]
    let page: Int
    let totalPages: Int
}

struct CalendarDay: Codable {
    let date: String
    let completedCount: Int
}

struct CalendarResponse: Codable {
    let days: [CalendarDay]
}
