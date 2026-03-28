import WidgetKit
import SwiftUI

// MARK: - Widget Theme (duplicated from RyddeTheme for widget target isolation)

enum WidgetTheme {
    static let fjord = Color(red: 0x1B / 255, green: 0x3A / 255, blue: 0x4B / 255)
    static let moss = Color(red: 0x4A / 255, green: 0x7A / 255, blue: 0x42 / 255)
    static let stone = Color(red: 0x8B / 255, green: 0x9A / 255, blue: 0x8E / 255)
    static let snow = Color(red: 0xF7 / 255, green: 0xF9 / 255, blue: 0xF8 / 255)
    static let linen = Color(red: 0xF0 / 255, green: 0xED / 255, blue: 0xE6 / 255)
    static let frost = Color(red: 0xE8 / 255, green: 0xF0 / 255, blue: 0xED / 255)
    static let mist = Color(red: 0xC8 / 255, green: 0xD5 / 255, blue: 0xCE / 255)
    static let birch = Color(red: 0xD4 / 255, green: 0xC5 / 255, blue: 0xA9 / 255)
    static let ember = Color(red: 0xC4 / 255, green: 0x5D / 255, blue: 0x3E / 255)
    static let midnight = Color(red: 0x0F / 255, green: 0x1F / 255, blue: 0x28 / 255)
    static let dew = Color(red: 0xD5 / 255, green: 0xE5 / 255, blue: 0xD1 / 255)
    static let matteCard = Color(red: 0xF7 / 255, green: 0xF5 / 255, blue: 0xF0 / 255)
    static let matteBorder = Color(red: 0xD8 / 255, green: 0xD3 / 255, blue: 0xC8 / 255)
    static let darkBg = Color(red: 0x0F / 255, green: 0x1F / 255, blue: 0x28 / 255)
    static let darkCard = Color(red: 0x1B / 255, green: 0x3A / 255, blue: 0x4B / 255)
    static let darkMoss = Color(red: 0x5A / 255, green: 0x9A / 255, blue: 0x52 / 255)
}

// MARK: - Room Freshness Model

struct RoomFreshness: Codable {
    let name: String
    let daysSinceClean: Int? // nil = never
}

// MARK: - Timeline Entry

struct CleanWidgetEntry: TimelineEntry {
    let date: Date
    let lastTaskTitle: String?
    let lastTaskRoom: String?
    let lastCompletedAt: Date?
    let roomFreshness: [RoomFreshness]
}

// MARK: - Timeline Provider

struct CleanWidgetProvider: TimelineProvider {
    private let suiteName = "group.app.rydde.ios"

    func placeholder(in context: Context) -> CleanWidgetEntry {
        CleanWidgetEntry(
            date: Date(),
            lastTaskTitle: "Kitchen counters",
            lastTaskRoom: "Kitchen",
            lastCompletedAt: Date(),
            roomFreshness: [
                RoomFreshness(name: "Kitchen", daysSinceClean: 2),
                RoomFreshness(name: "Bathroom", daysSinceClean: 11),
                RoomFreshness(name: "Bedroom", daysSinceClean: nil),
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CleanWidgetEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CleanWidgetEntry>) -> Void) {
        let entry = readEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func readEntry() -> CleanWidgetEntry {
        let d = UserDefaults(suiteName: suiteName)
        let title = d?.string(forKey: "lastTaskTitle")
        let room = d?.string(forKey: "lastTaskRoom")
        let ts = d?.double(forKey: "lastCompletedAt")
        let lastDate = (ts ?? 0) > 0 ? Date(timeIntervalSince1970: ts!) : nil

        var freshness: [RoomFreshness] = []
        if let data = d?.data(forKey: "roomFreshness") {
            freshness = (try? JSONDecoder().decode([RoomFreshness].self, from: data)) ?? []
        }

        return CleanWidgetEntry(
            date: Date(),
            lastTaskTitle: title,
            lastTaskRoom: room,
            lastCompletedAt: lastDate,
            roomFreshness: freshness
        )
    }
}

// MARK: - Entry View Dispatcher

struct CleanWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    let entry: CleanWidgetEntry

    var body: some View {
        switch family {
        case .systemMedium:
            CleanWidgetMediumView(entry: entry, colorScheme: colorScheme)
        default:
            CleanWidgetSmallView(entry: entry, colorScheme: colorScheme)
        }
    }
}

// MARK: - Small Widget

struct CleanWidgetSmallView: View {
    let entry: CleanWidgetEntry
    let colorScheme: ColorScheme

    private var bg: Color { colorScheme == .dark ? WidgetTheme.darkBg : WidgetTheme.linen }
    private var textPrimary: Color { colorScheme == .dark ? WidgetTheme.snow : WidgetTheme.fjord }
    private var textSecondary: Color { colorScheme == .dark ? WidgetTheme.mist : WidgetTheme.stone }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("rydde")
                .font(.custom("DMSans-Medium", size: 14))
                .foregroundColor(textSecondary)

            Spacer()

            if let title = entry.lastTaskTitle, let room = entry.lastTaskRoom {
                Text(room)
                    .font(.custom("DMSans-Medium", size: 11))
                    .foregroundColor(textSecondary)
                    .textCase(.uppercase)
                Text(title)
                    .font(.custom("DMSans-Medium", size: 15))
                    .foregroundColor(textPrimary)
                    .lineLimit(2)
                if let lastDate = entry.lastCompletedAt {
                    Text(lastDate, style: .relative)
                        .font(.custom("DMSans-Regular", size: 12))
                        .foregroundColor(textSecondary)
                }
            } else {
                Text("Ready to clean")
                    .font(.custom("DMSans-SemiBold", size: 16))
                    .foregroundColor(textPrimary)
                Text("Tap to start a session")
                    .font(.custom("DMSans-Regular", size: 12))
                    .foregroundColor(textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Medium Widget

struct CleanWidgetMediumView: View {
    let entry: CleanWidgetEntry
    let colorScheme: ColorScheme

    private var bg: Color { colorScheme == .dark ? WidgetTheme.darkBg : WidgetTheme.linen }
    private var textPrimary: Color { colorScheme == .dark ? WidgetTheme.snow : WidgetTheme.fjord }
    private var textSecondary: Color { colorScheme == .dark ? WidgetTheme.mist : WidgetTheme.stone }
    private var cardBg: Color { colorScheme == .dark ? WidgetTheme.darkCard : WidgetTheme.matteCard }
    private var accent: Color { colorScheme == .dark ? WidgetTheme.darkMoss : WidgetTheme.moss }

    var body: some View {
        HStack(spacing: 16) {
            // Left: last task info
            VStack(alignment: .leading, spacing: 4) {
                Text("rydde")
                    .font(.custom("DMSans-Medium", size: 14))
                    .foregroundColor(textSecondary)

                Spacer()

                if let title = entry.lastTaskTitle, let room = entry.lastTaskRoom {
                    Text(room)
                        .font(.custom("DMSans-Medium", size: 11))
                        .foregroundColor(textSecondary)
                        .textCase(.uppercase)
                    Text(title)
                        .font(.custom("DMSans-Medium", size: 15))
                        .foregroundColor(textPrimary)
                        .lineLimit(2)
                    if let lastDate = entry.lastCompletedAt {
                        Text(lastDate, style: .relative)
                            .font(.custom("DMSans-Regular", size: 12))
                            .foregroundColor(textSecondary)
                    }
                } else {
                    Text("Ready to clean")
                        .font(.custom("DMSans-SemiBold", size: 16))
                        .foregroundColor(textPrimary)
                    Text("Tap to start")
                        .font(.custom("DMSans-Regular", size: 12))
                        .foregroundColor(textSecondary)
                }
            }

            // Right: room health + buttons
            VStack(alignment: .leading, spacing: 6) {
                // Room health dots (max 4, sorted by staleness)
                let sortedRooms = entry.roomFreshness
                    .sorted { ($0.daysSinceClean ?? 999) > ($1.daysSinceClean ?? 999) }

                let displayRooms = Array(sortedRooms.prefix(4))
                let overflow = sortedRooms.count - displayRooms.count

                ForEach(Array(displayRooms.enumerated()), id: \.offset) { _, room in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(freshnessColor(days: room.daysSinceClean))
                            .frame(width: 8, height: 8)
                        Text(room.name)
                            .font(.custom("DMSans-Regular", size: 11))
                            .foregroundColor(textSecondary)
                            .lineLimit(1)
                    }
                }

                if overflow > 0 {
                    Text("+\(overflow) more")
                        .font(.custom("DMSans-Regular", size: 10))
                        .foregroundColor(textSecondary)
                }

                Spacer()

                HStack(spacing: 6) {
                    Link(destination: URL(string: "rydde://home?duration=10")!) {
                        Text("10 min")
                            .font(.custom("DMSans-Medium", size: 11))
                            .foregroundColor(accent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(accent.opacity(0.15))
                            .cornerRadius(6)
                    }
                    Link(destination: URL(string: "rydde://home?duration=15")!) {
                        Text("15 min")
                            .font(.custom("DMSans-Medium", size: 11))
                            .foregroundColor(accent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(accent.opacity(0.15))
                            .cornerRadius(6)
                    }
                }
            }
        }
    }

    private func freshnessColor(days: Int?) -> Color {
        guard let days else { return WidgetTheme.ember } // never cleaned
        if days <= 7 { return WidgetTheme.moss }         // fresh
        if days <= 14 { return WidgetTheme.birch }       // getting stale
        return WidgetTheme.ember                          // overdue
    }
}

// MARK: - Widget Configuration

struct CleanWidget: Widget {
    let kind = "CleanWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CleanWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                CleanWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        ContainerRelativeShape()
                            .fill(Color.clear)
                    }
                    .widgetURL(URL(string: "rydde://home"))
            } else {
                CleanWidgetEntryView(entry: entry)
                    .padding()
                    .widgetURL(URL(string: "rydde://home"))
            }
        }
        .configurationDisplayName("Rydde")
        .description("See what's fresh and start a session.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
