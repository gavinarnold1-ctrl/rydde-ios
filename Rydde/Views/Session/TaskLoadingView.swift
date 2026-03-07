import SwiftUI

struct TaskLoadingView: View {
    @State private var rotation: Double = 0

    var body: some View {
        VStack(spacing: RyddeTheme.Spacing.lg) {
            ArcSpinner(size: 60)

            Text("Finding something useful...")
                .font(RyddeTheme.Fonts.bodySmall14)
                .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
        }
    }
}
