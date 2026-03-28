import Foundation
import WidgetKit

struct RoomFreshnessData: Codable {
    let name: String
    let daysSinceClean: Int? // nil = never
}

final class WidgetService {
    static let shared = WidgetService()
    private let suiteName = "group.app.rydde.ios"

    private init() {}

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    func updateAfterSession(taskTitle: String, room: String) {
        let d = defaults
        d?.set(taskTitle, forKey: "lastTaskTitle")
        d?.set(room, forKey: "lastTaskRoom")
        d?.set(Date().timeIntervalSince1970, forKey: "lastCompletedAt")

        WidgetCenter.shared.reloadAllTimelines()
    }

    func updateRoomFreshness(_ rooms: [RoomFreshnessData]) {
        guard let data = try? JSONEncoder().encode(rooms) else { return }
        defaults?.set(data, forKey: "roomFreshness")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
