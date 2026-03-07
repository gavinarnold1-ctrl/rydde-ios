import SwiftUI

struct TaskLog: View {
    let tasks: [TaskEntry]
    let rooms: [RoomFilter]
    @Binding var selectedRoom: RoomFilter?
    let isLoading: Bool
    let onLoadMore: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: RyddeTheme.Spacing.md) {
            roomFilterRow

            if filteredTasks.isEmpty && !isLoading {
                emptyState
            } else {
                LazyVStack(spacing: RyddeTheme.Spacing.sm) {
                    ForEach(filteredTasks) { task in
                        TaskEntryCard(task: task)
                            .onAppear {
                                if task.id == filteredTasks.last?.id {
                                    onLoadMore()
                                }
                            }
                    }

                    if isLoading {
                        ArcSpinner(size: 24)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RyddeTheme.Spacing.md)
                    }
                }
            }
        }
    }

    private var filteredTasks: [TaskEntry] {
        guard let room = selectedRoom else { return tasks }
        return tasks.filter { $0.room == room.name }
    }

    // MARK: - Room Filter Row

    private var roomFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: RyddeTheme.Spacing.sm) {
                FilterChip(label: "All", isSelected: selectedRoom == nil) {
                    selectedRoom = nil
                }

                ForEach(rooms) { room in
                    FilterChip(label: room.name, isSelected: selectedRoom == room) {
                        selectedRoom = (selectedRoom == room) ? nil : room
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: RyddeTheme.Spacing.sm) {
            Text("No tasks yet")
                .font(RyddeTheme.Fonts.body)
                .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, RyddeTheme.Spacing.xxl)
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(RyddeTheme.Fonts.bodySmall)
                .foregroundColor(isSelected ? Color(RyddeTheme.Colors.accent) : Color(RyddeTheme.Colors.secondaryText))
                .padding(.horizontal, RyddeTheme.Spacing.md)
                .padding(.vertical, RyddeTheme.Spacing.xs + 2)
                .background(isSelected ? Color(RyddeTheme.Colors.selectedBackground) : Color(RyddeTheme.Colors.cardBackground))
                .cornerRadius(RyddeTheme.CornerRadius.button)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .animation(.easeOut(duration: 0.3), value: isSelected)
    }
}

// MARK: - Task Entry Card

private struct TaskEntryCard: View {
    let task: TaskEntry

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: RyddeTheme.Spacing.xs) {
                Text(task.room.uppercased())
                    .font(RyddeTheme.Fonts.bodyMedium11)
                    .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                    .kerning(2)

                Text(task.title)
                    .font(RyddeTheme.Fonts.bodyMedium)
                    .foregroundColor(task.isSkipped ? Color(RyddeTheme.Colors.secondaryText) : Color(RyddeTheme.Colors.primaryText))
                    .lineLimit(2)

                HStack(spacing: RyddeTheme.Spacing.sm) {
                    if task.isSkipped {
                        Text("Skipped")
                            .font(RyddeTheme.Fonts.caption)
                            .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                    }

                    if let duration = task.durationMinutes {
                        Text(durationLabel(duration))
                            .font(.custom("DMSans-Regular", size: 10))
                            .foregroundColor(Color(RyddeTheme.Colors.accent))
                            .padding(.horizontal, RyddeTheme.Spacing.sm)
                            .padding(.vertical, 2)
                            .background(Color(RyddeTheme.Colors.rationaleBackground))
                            .cornerRadius(10)
                    }
                }
            }

            Spacer()

            Text(relativeDate(task.completedAt ?? task.createdAt))
                .font(.custom("DMSans-Regular", size: 12))
                .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
        }
        .padding(RyddeTheme.Spacing.md)
        .background(Color(RyddeTheme.Colors.cardBackground))
        .cornerRadius(RyddeTheme.CornerRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.card)
                .stroke(Color(RyddeTheme.Colors.border), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    private func durationLabel(_ minutes: Int) -> String {
        minutes >= 60 ? "\(minutes / 60) hr" : "\(minutes) min"
    }

    private func relativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }

        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: now)).day ?? 0

        if days <= 6 {
            return "\(days) days ago"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
