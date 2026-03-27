import Foundation
import WidgetKit

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

        let currentStreak = d?.integer(forKey: "currentStreak") ?? 0
        let lastStreakDate = d?.string(forKey: "lastStreakDate") ?? ""
        let today = Self.dateString(from: Date())
        let yesterday = Self.dateString(from: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())

        if lastStreakDate == today {
            // Already counted today
        } else if lastStreakDate == yesterday {
            d?.set(currentStreak + 1, forKey: "currentStreak")
            d?.set(today, forKey: "lastStreakDate")
        } else {
            d?.set(1, forKey: "currentStreak")
            d?.set(today, forKey: "lastStreakDate")
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    static func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
