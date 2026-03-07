import SwiftUI

struct CompletionView: View {
    let taskTitle: String
    let onDismiss: () -> Void

    @State private var hasAppeared = false

    var body: some View {
        ZStack {
            Color(RyddeTheme.Colors.background)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: RyddeTheme.Spacing.md) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 48))
                    .foregroundColor(Color(RyddeTheme.Colors.accent))
                    .accessibilityHidden(true)

                Text("Nice work.")
                    .font(RyddeTheme.Fonts.headingMedium)
                    .foregroundColor(Color(RyddeTheme.Colors.primaryText))

                Text(taskTitle)
                    .font(RyddeTheme.Fonts.bodySmall14)
                    .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                    .multilineTextAlignment(.center)
            }
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 20)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Task completed: \(taskTitle)")
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
