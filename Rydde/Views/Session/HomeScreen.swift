import SwiftUI

enum AppTab {
    case clean
    case history
}

struct HomeScreen: View {
    @State private var selectedDuration: Int?
    @State private var activeSession: SessionFlowState?
    @State private var selectedTab: AppTab = .clean
    @State private var showSettings = false
    @Environment(\.deepLinkDuration) private var deepLinkDuration
    @Environment(\.deepLinkAction) private var deepLinkAction

    var body: some View {
        ZStack {
            Color(RyddeTheme.Colors.background)
                .ignoresSafeArea()

            if let session = activeSession {
                SessionFlow(state: session, onDismiss: {
                    activeSession = nil
                    selectedDuration = nil
                })
                .transition(.opacity)
            } else {
                mainContent
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.5), value: activeSession != nil)
        .onChange(of: deepLinkDuration.wrappedValue) { _, duration in
            if let duration {
                selectedDuration = duration
                activeSession = SessionFlowState(durationMinutes: duration)
                deepLinkDuration.wrappedValue = nil
            }
        }
        .onChange(of: deepLinkAction.wrappedValue) { _, action in
            if let action {
                handleDeepLinkAction(action)
                deepLinkAction.wrappedValue = nil
            }
        }
    }

    private func handleDeepLinkAction(_ action: DeepLinkAction) {
        switch action {
        case .done(let sessionId):
            Task {
                let body = UpdateSessionRequest(status: "done")
                let _: Session? = try? await APIService.shared.patch(
                    endpoint: "/api/sessions/\(sessionId.uuidString)",
                    body: body
                )
                await LiveActivityService.shared.end()
                activeSession = nil
            }
        case .skip(let sessionId):
            Task {
                let body = UpdateSessionRequest(status: "skipped")
                let _: Session? = try? await APIService.shared.patch(
                    endpoint: "/api/sessions/\(sessionId.uuidString)",
                    body: body
                )
                await LiveActivityService.shared.end()
                activeSession = nil
            }
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case .clean:
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, RyddeTheme.Spacing.lg)
                        .padding(.top, RyddeTheme.Spacing.md)

                    Spacer()

                    durationSelector
                        .padding(.horizontal, RyddeTheme.Spacing.lg)

                    Spacer()
                }

            case .history:
                HistoryScreen()
            }

            tabBar
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("rydde")
                .font(RyddeTheme.Fonts.headingSmall)
                .foregroundColor(Color(RyddeTheme.Colors.primaryText))

            Spacer()

            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Settings")
            .fullScreenCover(isPresented: $showSettings) {
                SettingsScreen()
            }
        }
    }

    // MARK: - Duration Selector

    private var durationSelector: some View {
        VStack(spacing: RyddeTheme.Spacing.lg) {
            Text("How much time do you have?")
                .font(RyddeTheme.Fonts.bodyMedium18)
                .foregroundColor(Color(RyddeTheme.Colors.primaryText))

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: RyddeTheme.Spacing.sm),
                GridItem(.flexible(), spacing: RyddeTheme.Spacing.sm),
            ], spacing: RyddeTheme.Spacing.sm) {
                DurationButton(label: "10 min", minutes: 10, selected: $selectedDuration)
                DurationButton(label: "15 min", minutes: 15, selected: $selectedDuration)
                DurationButton(label: "30 min", minutes: 30, selected: $selectedDuration)
                DurationButton(label: "1 hour", minutes: 60, selected: $selectedDuration)
            }

            Button(action: startSession) {
                Text("Start")
                    .font(RyddeTheme.Fonts.buttonLabel)
                    .foregroundColor(Color(RyddeTheme.Colors.snow))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(RyddeTheme.Colors.accent))
                    .cornerRadius(RyddeTheme.CornerRadius.button)
            }
            .disabled(selectedDuration == nil)
            .opacity(selectedDuration == nil ? 0.4 : 1.0)
            .accessibilityLabel("Start cleaning session")
            .accessibilityHint(selectedDuration.map { "Start a \($0) minute session" } ?? "Select a duration first")
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 80) {
            Button(action: { selectedTab = .clean }) {
                Image(systemName: "house")
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == .clean ? Color(RyddeTheme.Colors.accent) : Color(RyddeTheme.Colors.secondaryText))
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Clean")

            Button(action: { selectedTab = .history }) {
                Image(systemName: "clock")
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == .history ? Color(RyddeTheme.Colors.accent) : Color(RyddeTheme.Colors.secondaryText))
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("History")
        }
        .padding(.bottom, RyddeTheme.Spacing.lg)
    }

    private func startSession() {
        guard let duration = selectedDuration else { return }
        activeSession = SessionFlowState(durationMinutes: duration)
    }
}

// MARK: - Duration Button

private struct DurationButton: View {
    let label: String
    let minutes: Int
    @Binding var selected: Int?

    private var isSelected: Bool { selected == minutes }

    var body: some View {
        Button(action: { selected = minutes }) {
            Text(label)
                .font(RyddeTheme.Fonts.durationPicker)
                .foregroundColor(isSelected ? Color(RyddeTheme.Colors.accent) : Color(RyddeTheme.Colors.primaryText))
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(isSelected ? Color(RyddeTheme.Colors.selectedBackground) : Color(RyddeTheme.Colors.cardBackground))
                .cornerRadius(RyddeTheme.CornerRadius.card)
                .overlay(
                    RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.card)
                        .stroke(
                            isSelected ? Color(RyddeTheme.Colors.accent) : Color(RyddeTheme.Colors.border),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label) session")
        .animation(.easeOut(duration: 0.3), value: isSelected)
    }
}
