import SwiftUI

struct TaskScreen: View {
    let task: GeneratedTask
    let timerSeconds: Int
    let onDone: () -> Void
    let onSkip: () -> Void

    @State private var doneButtonScale: CGFloat = 1.0
    @State private var showCheck = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: RyddeTheme.Spacing.lg) {
                    roomLabel
                    taskTitle
                    taskDescription
                    rationaleBox
                    timerDisplay
                }
                .padding(.horizontal, RyddeTheme.Spacing.lg)
                .padding(.top, RyddeTheme.Spacing.xl)
            }

            actionButtons
        }
    }

    // MARK: - Room Label

    private var roomLabel: some View {
        Text(task.room.uppercased())
            .font(RyddeTheme.Fonts.bodyMedium11)
            .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
            .kerning(2)
    }

    // MARK: - Task Title

    private var taskTitle: some View {
        Text(task.title)
            .font(RyddeTheme.Fonts.headingTask)
            .foregroundColor(Color(RyddeTheme.Colors.primaryText))
    }

    // MARK: - Task Description

    private var taskDescription: some View {
        Text(task.description)
            .font(RyddeTheme.Fonts.bodyDynamic)
            .foregroundColor(Color(RyddeTheme.Colors.primaryText))
            .lineSpacing(15 * 0.6)
    }

    // MARK: - Rationale Box

    private var rationaleBox: some View {
        VStack(alignment: .leading, spacing: RyddeTheme.Spacing.xs) {
            Text("Why this?")
                .font(RyddeTheme.Fonts.bodyMedium12)
                .foregroundColor(Color(RyddeTheme.Colors.accent))

            Text(task.rationale)
                .font(RyddeTheme.Fonts.bodySmallDynamic)
                .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                .lineSpacing(13 * 0.4)
        }
        .padding(RyddeTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(RyddeTheme.Colors.rationaleBackground))
        .cornerRadius(RyddeTheme.CornerRadius.card)
    }

    // MARK: - Timer

    private var timerDisplay: some View {
        HStack {
            Spacer()
            Text(formattedTime)
                .font(RyddeTheme.Fonts.timer)
                .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                .monospacedDigit()
                .accessibilityLabel("Timer: \(timerSeconds / 60) minutes \(timerSeconds % 60) seconds")
            Spacer()
        }
        .padding(.top, RyddeTheme.Spacing.md)
    }

    private var formattedTime: String {
        let minutes = timerSeconds / 60
        let seconds = timerSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: RyddeTheme.Spacing.md) {
            Button(action: handleDone) {
                ZStack {
                    Text("Done")
                        .font(RyddeTheme.Fonts.buttonLabel)
                        .foregroundColor(Color(RyddeTheme.Colors.snow))
                        .opacity(showCheck ? 0 : 1)

                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(RyddeTheme.Colors.snow))
                        .opacity(showCheck ? 1 : 0)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(RyddeTheme.Colors.accent))
                .cornerRadius(RyddeTheme.CornerRadius.button)
            }
            .scaleEffect(doneButtonScale)
            .accessibilityLabel("Mark task as done")

            Button(action: onSkip) {
                Text("Skip this one")
                    .font(RyddeTheme.Fonts.bodySmall14)
                    .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                    .frame(minWidth: 44, minHeight: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Skip this task")
        }
        .padding(.horizontal, RyddeTheme.Spacing.lg)
        .padding(.bottom, RyddeTheme.Spacing.lg)
    }

    private func handleDone() {
        withAnimation(.easeOut(duration: 0.1)) {
            doneButtonScale = 0.95
        }
        withAnimation(.easeOut(duration: 0.15).delay(0.1)) {
            doneButtonScale = 1.0
            showCheck = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            onDone()
        }
    }
}
