import WidgetKit
import SwiftUI

struct CleanWidgetEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let lastTaskTitle: String?
    let lastTaskRoom: String?
    let lastCompletedAt: Date?
}

struct CleanWidgetProvider: TimelineProvider {
    private let suiteName = "group.app.rydde.ios"

    func placeholder(in context: Context) -> CleanWidgetEntry {
        CleanWidgetEntry(date: Date(), streak: 3, lastTaskTitle: "Kitchen counters", lastTaskRoom: "Kitchen", lastCompletedAt: Date())
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
        let streak = d?.integer(forKey: "currentStreak") ?? 0
        let title = d?.string(forKey: "lastTaskTitle")
        let room = d?.string(forKey: "lastTaskRoom")
        let ts = d?.double(forKey: "lastCompletedAt")
        let lastDate = (ts ?? 0) > 0 ? Date(timeIntervalSince1970: ts!) : nil
        return CleanWidgetEntry(date: Date(), streak: streak, lastTaskTitle: title, lastTaskRoom: room, lastCompletedAt: lastDate)
    }
}

struct CleanWidgetSmallView: View {
    let entry: CleanWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("rydde")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            Spacer()

            if entry.streak > 0 {
                Text("\(entry.streak)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                Text("day streak")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            } else {
                Text("Start\ncleaning")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CleanWidgetMediumView: View {
    let entry: CleanWidgetEntry

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("rydde")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)

                Spacer()

                if entry.streak > 0 {
                    Text("\(entry.streak)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    Text("day streak")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                } else {
                    Text("No streak yet")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                if let title = entry.lastTaskTitle, let room = entry.lastTaskRoom {
                    Text(room)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    if let lastDate = entry.lastCompletedAt {
                        Text(lastDate, style: .relative)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("No tasks yet")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 8) {
                    Link(destination: URL(string: "rydde://clean?duration=10")!) {
                        Text("10 min")
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.green.opacity(0.2))
                            .cornerRadius(8)
                    }
                    Link(destination: URL(string: "rydde://clean?duration=15")!) {
                        Text("15 min")
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.green.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}

struct CleanWidget: Widget {
    let kind = "CleanWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CleanWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                CleanWidgetSmallView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                    .widgetURL(URL(string: "rydde://clean"))
            } else {
                CleanWidgetSmallView(entry: entry)
                    .padding()
                    .widgetURL(URL(string: "rydde://clean"))
            }
        }
        .configurationDisplayName("Rydde")
        .description("Track your cleaning streak and start sessions.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
