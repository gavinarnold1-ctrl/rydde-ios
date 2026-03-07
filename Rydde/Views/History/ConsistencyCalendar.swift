import SwiftUI

struct ConsistencyCalendar: View {
    let completedDates: Set<String>
    @Binding var displayedMonth: Date

    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var body: some View {
        VStack(spacing: RyddeTheme.Spacing.sm) {
            monthHeader
            dayOfWeekRow
            dayGrid
        }
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    if value.translation.width < -30 {
                        navigateMonth(by: 1)
                    } else if value.translation.width > 30 {
                        navigateMonth(by: -1)
                    }
                }
        )
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Text(monthYearString)
                .font(RyddeTheme.Fonts.bodyMedium)
                .foregroundColor(Color(RyddeTheme.Colors.fjord))
            Spacer()
        }
    }

    // MARK: - Day of Week Row

    private var dayOfWeekRow: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
            ForEach(dayLabels, id: \.self) { label in
                Text(label)
                    .font(RyddeTheme.Fonts.caption)
                    .foregroundColor(Color(RyddeTheme.Colors.stone))
                    .frame(height: 16)
            }
        }
    }

    // MARK: - Day Grid

    private var dayGrid: some View {
        let days = daysInMonth()
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 4) {
            ForEach(days, id: \.self) { day in
                dayCell(for: day)
            }
        }
    }

    @ViewBuilder
    private func dayCell(for day: DayItem) -> some View {
        switch day {
        case .empty:
            Color.clear.frame(height: 14)
        case .day(let date, let state):
            ZStack {
                if state == .today || state == .completedToday {
                    Circle()
                        .stroke(Color(RyddeTheme.Colors.sage), lineWidth: 1)
                        .frame(width: 12, height: 12)
                }

                Circle()
                    .fill(circleFill(for: state))
                    .frame(width: 8, height: 8)
            }
            .frame(height: 14)
        }
    }

    private func circleFill(for state: DayState) -> Color {
        switch state {
        case .completed, .completedToday:
            return Color(RyddeTheme.Colors.moss)
        case .noSession, .today:
            return Color(RyddeTheme.Colors.frost)
        case .future:
            return .clear
        }
    }

    // MARK: - Helpers

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private func navigateMonth(by offset: Int) {
        withAnimation(.easeOut(duration: 0.3)) {
            if let newMonth = calendar.date(byAdding: .month, value: offset, to: displayedMonth) {
                displayedMonth = newMonth
            }
        }
    }

    private func daysInMonth() -> [DayItem] {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingEmpties = firstWeekday - 1

        let today = calendar.startOfDay(for: Date())

        var items: [DayItem] = Array(repeating: .empty, count: leadingEmpties)

        for day in range {
            var dayComponents = components
            dayComponents.day = day
            guard let date = calendar.date(from: dayComponents) else { continue }

            let dateString = dateFormatter.string(from: date)
            let startOfDate = calendar.startOfDay(for: date)
            let isToday = startOfDate == today
            let isFuture = startOfDate > today
            let hasCompletion = completedDates.contains(dateString)

            let state: DayState
            if isFuture {
                state = .future
            } else if isToday && hasCompletion {
                state = .completedToday
            } else if isToday {
                state = .today
            } else if hasCompletion {
                state = .completed
            } else {
                state = .noSession
            }

            items.append(.day(date: date, state: state))
        }

        return items
    }
}

enum DayItem: Hashable {
    case empty
    case day(date: Date, state: DayState)
}

enum DayState: Hashable {
    case completed
    case completedToday
    case today
    case noSession
    case future
}
