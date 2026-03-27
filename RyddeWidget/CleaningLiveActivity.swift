import SwiftUI
import WidgetKit
import ActivityKit

struct CleaningLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CleaningActivityAttributes.self) { context in
            // Lock Screen view
            lockScreenView(context: context)
                .activityBackgroundTint(.black.opacity(0.8))
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.room)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.status == "active" {
                        Text(context.state.endTime, style: .timer)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                            .monospacedDigit()
                    } else {
                        Text("Done!")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.taskTitle)
                        .font(.system(size: 15))
                        .lineLimit(2)
                        .padding(.top, 4)

                    HStack(spacing: 12) {
                        Link(destination: URL(string: "rydde://done?sessionId=\(context.attributes.sessionId.uuidString)")!) {
                            Text("Done")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(.green)
                                .cornerRadius(8)
                        }
                        Link(destination: URL(string: "rydde://skip?sessionId=\(context.attributes.sessionId.uuidString)")!) {
                            Text("Skip")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top, 8)
                }
            } compactLeading: {
                Image(systemName: "sparkles")
                    .foregroundColor(.green)
            } compactTrailing: {
                if context.state.status == "active" {
                    Text(context.state.endTime, style: .timer)
                        .font(.system(size: 14, design: .monospaced))
                        .monospacedDigit()
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            } minimal: {
                Image(systemName: "sparkles")
                    .foregroundColor(.green)
            }
        }
    }

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<CleaningActivityAttributes>) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.room)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    Text(context.attributes.taskTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }

                Spacer()

                if context.state.status == "active" {
                    Text(context.state.endTime, style: .timer)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .monospacedDigit()
                        .foregroundColor(.green)
                } else {
                    Text(context.state.status == "done" ? "Done!" : "Time's up!")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.green)
                }
            }

            HStack(spacing: 12) {
                Link(destination: URL(string: "rydde://done?sessionId=\(context.attributes.sessionId.uuidString)")!) {
                    Text("Done")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.green)
                        .cornerRadius(10)
                }
                Link(destination: URL(string: "rydde://skip?sessionId=\(context.attributes.sessionId.uuidString)")!) {
                    Text("Skip")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.white.opacity(0.15))
                        .cornerRadius(10)
                }
            }
        }
        .padding(16)
    }
}
