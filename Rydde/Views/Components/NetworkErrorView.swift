import SwiftUI

struct NetworkErrorView: View {
    let message: String
    let onRetry: () -> Void

    init(
        message: String = "Couldn't connect. Check your connection and try again.",
        onRetry: @escaping () -> Void
    ) {
        self.message = message
        self.onRetry = onRetry
    }

    var body: some View {
        VStack(spacing: RyddeTheme.Spacing.lg) {
            Text(message)
                .font(RyddeTheme.Fonts.body)
                .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                .multilineTextAlignment(.center)

            Button(action: onRetry) {
                Text("Try again")
                    .font(RyddeTheme.Fonts.buttonLabel)
                    .foregroundColor(Color(RyddeTheme.Colors.snow))
                    .frame(width: 200, height: 48)
                    .background(Color(RyddeTheme.Colors.accent))
                    .cornerRadius(RyddeTheme.CornerRadius.button)
            }
            .accessibilityLabel("Retry")
        }
        .padding(RyddeTheme.Spacing.lg)
    }
}
