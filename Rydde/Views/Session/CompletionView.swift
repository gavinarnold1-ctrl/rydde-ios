import SwiftUI

struct CompletionView: View {
    let taskTitle: String
    let onDismiss: () -> Void

    @State private var hasAppeared = false

    var body: some View {
        ZStack {
            Color(RyddeTheme.Colors.snow)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: RyddeTheme.Spacing.md) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 48))
                    .foregroundColor(Color(RyddeTheme.Colors.moss))

                Text("Nice work.")
                    .font(RyddeTheme.Fonts.headingMedium)
                    .foregroundColor(Color(RyddeTheme.Colors.fjord))

                Text(taskTitle)
                    .font(RyddeTheme.Fonts.bodySmall14)
                    .foregroundColor(Color(RyddeTheme.Colors.stone))
                    .multilineTextAlignment(.center)
            }
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 10)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                hasAppeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onDismiss()
            }
        }
    }
}
