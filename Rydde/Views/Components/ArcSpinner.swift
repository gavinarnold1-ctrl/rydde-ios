import SwiftUI

/// Sage/Moss arc spinner matching the brand motion spec.
/// Uses a continuous 2s sweep with no spring/bounce.
struct ArcSpinner: View {
    let size: CGFloat

    @State private var rotation: Double = 0

    init(size: CGFloat = 24) {
        self.size = size
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(RyddeTheme.Colors.sage), lineWidth: lineWidth)
                .frame(width: size, height: size)

            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(
                    Color(RyddeTheme.Colors.accent),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotation))
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }

    private var lineWidth: CGFloat {
        size <= 30 ? 2 : 3
    }
}
