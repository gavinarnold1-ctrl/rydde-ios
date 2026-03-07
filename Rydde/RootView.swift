import SwiftUI

struct RootView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var isCheckingStatus = true
    @State private var hasHousehold = false

    var body: some View {
        Group {
            if isCheckingStatus {
                loadingView
            } else if !authService.isAuthenticated {
                WelcomeView()
            } else if !hasHousehold {
                OnboardingFlow(onComplete: {
                    hasHousehold = true
                })
            } else {
                HomeScreen()
            }
        }
        .animation(.easeOut(duration: 0.5), value: authService.isAuthenticated)
        .animation(.easeOut(duration: 0.5), value: isCheckingStatus)
        .animation(.easeOut(duration: 0.5), value: hasHousehold)
        .task {
            await checkAuthStatus()
        }
        .onChange(of: authService.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                Task { await checkHousehold() }
            } else {
                hasHousehold = false
            }
        }
    }

    private var loadingView: some View {
        ZStack {
            Color(RyddeTheme.Colors.fjord)
                .ignoresSafeArea()
            Text("rydde")
                .font(RyddeTheme.Fonts.headingLarge)
                .foregroundColor(Color(RyddeTheme.Colors.snow))
        }
    }

    private func checkAuthStatus() async {
        if authService.isAuthenticated {
            await checkHousehold()
        }
        isCheckingStatus = false
    }

    private func checkHousehold() async {
        do {
            let response: MeResponse = try await APIService.shared.get(endpoint: "/api/me")
            hasHousehold = response.household != nil
        } catch {
            hasHousehold = false
        }
    }
}

struct MeResponse: Codable {
    let user: User
    let household: Household?
}
