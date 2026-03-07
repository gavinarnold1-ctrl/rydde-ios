import SwiftUI

struct TaskLoadingView: View {
    @State private var rotation: Double = 0

    var body: some View {
        VStack(spacing: RyddeTheme.Spacing.lg) {
            ZStack {
                Circle()
                    .stroke(Color(RyddeTheme.Colors.sage), lineWidth: 3)
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(Color(RyddeTheme.Colors.moss), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(rotation))
            }

            Text("Finding something useful...")
                .font(RyddeTheme.Fonts.bodySmall14)
                .foregroundColor(Color(RyddeTheme.Colors.stone))
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}
