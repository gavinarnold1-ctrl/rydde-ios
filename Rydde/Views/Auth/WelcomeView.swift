import AuthenticationServices
import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var isSigningIn = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color(RyddeTheme.Colors.background)
                .ignoresSafeArea()

            VStack(spacing: RyddeTheme.Spacing.xxl) {
                Spacer()

                VStack(spacing: RyddeTheme.Spacing.sm) {
                    Text("rydde")
                        .font(RyddeTheme.Fonts.headingLarge)
                        .foregroundColor(Color(RyddeTheme.Colors.primaryText))

                    Text("less thinking, more living")
                        .font(RyddeTheme.Fonts.body)
                        .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                }

                Spacer()

                VStack(spacing: RyddeTheme.Spacing.md) {
                    if let errorMessage {
                        Text(errorMessage)
                            .font(RyddeTheme.Fonts.bodySmall)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            Task { await handleSignIn(result: result) }
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(RyddeTheme.CornerRadius.button)
                    .disabled(isSigningIn)
                    .opacity(isSigningIn ? 0.6 : 1.0)
                }
                .padding(.horizontal, RyddeTheme.Spacing.lg)
                .padding(.bottom, RyddeTheme.Spacing.xxl)
            }
        }
    }

    private func handleSignIn(result: Result<ASAuthorization, Error>) async {
        isSigningIn = true
        errorMessage = nil

        do {
            try await authService.handleSignInWithApple(result: result)
        } catch {
            errorMessage = error.localizedDescription
        }

        isSigningIn = false
    }
}
