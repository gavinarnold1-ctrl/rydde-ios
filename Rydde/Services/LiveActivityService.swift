import Foundation
import ActivityKit

@MainActor
final class LiveActivityService {
    static let shared = LiveActivityService()
    private var currentActivity: Activity<CleaningActivityAttributes>?

    private init() {}

    func start(sessionId: UUID, room: String, taskTitle: String, durationMinutes: Int) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = CleaningActivityAttributes(
            sessionId: sessionId,
            room: room,
            taskTitle: taskTitle,
            durationMinutes: durationMinutes
        )

        let endTime = Date().addingTimeInterval(TimeInterval(durationMinutes * 60))
        let state = CleaningActivityAttributes.ContentState(
            endTime: endTime,
            status: "active"
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: endTime),
                pushType: nil
            )
            currentActivity = activity
        } catch {
            print("Failed to start live activity: \(error)")
        }
    }

    func markTimesUp() {
        guard let activity = currentActivity else { return }
        let state = CleaningActivityAttributes.ContentState(
            endTime: Date(),
            status: "timesUp"
        )
        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    func end() {
        guard let activity = currentActivity else { return }
        let state = CleaningActivityAttributes.ContentState(
            endTime: Date(),
            status: "done"
        )
        Task {
            await activity.end(.init(state: state, staleDate: nil), dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }
}
