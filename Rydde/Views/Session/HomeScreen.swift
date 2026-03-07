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

    var body: some View {
        ZStack {
            Color(RyddeTheme.Colors.snow)
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
        .animation(.easeOut(duration: 0.2), value: activeSession != nil)
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
                .foregroundColor(Color(RyddeTheme.Colors.fjord))

            Spacer()

            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundColor(Color(RyddeTheme.Colors.stone))
            }
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
                .foregroundColor(Color(RyddeTheme.Colors.fjord))

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
                    .background(Color(RyddeTheme.Colors.moss))
                    .cornerRadius(RyddeTheme.CornerRadius.button)
            }
            .disabled(selectedDuration == nil)
            .opacity(selectedDuration == nil ? 0.4 : 1.0)
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 80) {
            Button(action: { selectedTab = .clean }) {
                Image(systemName: "house")
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == .clean ? Color(RyddeTheme.Colors.moss) : Color(RyddeTheme.Colors.stone))
            }

            Button(action: { selectedTab = .history }) {
                Image(systemName: "clock")
                    .font(.system(size: 24))
                    .foregroundColor(selectedTab == .history ? Color(RyddeTheme.Colors.moss) : Color(RyddeTheme.Colors.stone))
            }
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
                .foregroundColor(isSelected ? Color(RyddeTheme.Colors.moss) : Color(RyddeTheme.Colors.fjord))
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(isSelected ? Color(RyddeTheme.Colors.dew) : Color(RyddeTheme.Colors.frost))
                .cornerRadius(RyddeTheme.CornerRadius.card)
                .overlay(
                    RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.card)
                        .stroke(
                            isSelected ? Color(RyddeTheme.Colors.moss) : Color(RyddeTheme.Colors.mist),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.3), value: isSelected)
    }
}
