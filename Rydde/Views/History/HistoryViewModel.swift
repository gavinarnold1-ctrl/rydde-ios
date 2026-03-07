import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var tasks: [TaskEntry] = []
    @Published var completedDates: Set<String> = []
    @Published var availableRooms: [RoomFilter] = []
    @Published var selectedRoom: RoomFilter? = nil
    @Published var displayedMonth: Date = Date()
    @Published var isLoadingMore = false
    @Published var isInitialLoading = false
    @Published var error: String?

    private var currentPage = 1
    private var totalPages = 1
    private var hasLoaded = false

    func initialLoad() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        isInitialLoading = true
        error = nil
        await loadCalendar()
        await loadTasks(reset: true)
        isInitialLoading = false
    }

    func retry() async {
        hasLoaded = false
        await initialLoad()
    }

    func loadMoreIfNeeded() {
        guard !isLoadingMore, currentPage < totalPages else { return }
        Task { await loadTasks(reset: false) }
    }

    func filterByRoom(_ room: RoomFilter?) async {
        selectedRoom = room
        await loadTasks(reset: true)
    }

    private func loadCalendar() async {
        do {
            let response: CalendarResponse = try await APIService.shared.get(
                endpoint: "/api/tasks/calendar"
            )
            completedDates = Set(
                response.days
                    .filter { $0.completedCount > 0 }
                    .map { $0.date }
            )
        } catch {
            // Calendar is non-critical, fail silently
        }
    }

    private func loadTasks(reset: Bool) async {
        if reset {
            currentPage = 1
        } else {
            currentPage += 1
        }

        isLoadingMore = true

        var endpoint = "/api/tasks?page=\(currentPage)&limit=20"
        if let room = selectedRoom, room.id != nil {
            endpoint += "&room_id=\(room.id!.uuidString)"
        }

        do {
            let response: TaskListResponse = try await APIService.shared.get(endpoint: endpoint)
            totalPages = response.totalPages
            error = nil

            if reset {
                tasks = response.tasks
            } else {
                tasks.append(contentsOf: response.tasks)
            }

            buildRoomFilters()
        } catch {
            if reset && tasks.isEmpty {
                self.error = "Couldn't connect. Check your connection and try again."
            }
        }

        isLoadingMore = false
    }

    private func buildRoomFilters() {
        let roomNames = Set(tasks.map { $0.room })
        let sorted = roomNames.sorted()
        availableRooms = sorted.map { name in
            let roomId = tasks.first(where: { $0.room == name })?.roomId
            return RoomFilter(name: name, id: roomId)
        }
    }
}

struct RoomFilter: Identifiable, Equatable {
    let name: String
    let id: UUID?

    static func == (lhs: RoomFilter, rhs: RoomFilter) -> Bool {
        lhs.name == rhs.name
    }
}
