import Foundation
import ActivityKit

struct CleaningActivityAttributes: ActivityAttributes {
    let sessionId: UUID
    let room: String
    let taskTitle: String
    let durationMinutes: Int

    struct ContentState: Codable, Hashable {
        let endTime: Date
        let status: String // "active", "timesUp", "done"
    }
}
