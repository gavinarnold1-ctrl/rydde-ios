import SwiftUI

struct PainPointsStep: View {
    @Binding var selectedPainPoints: Set<String>
    let isSubmitting: Bool
    let errorMessage: String?
    var onComplete: () -> Void
    var onBack: () -> Void

    private let painPoints = [
        "Bathroom gets gross fast",
        "Dust builds up everywhere",
        "Kitchen is always messy",
        "Clutter accumulates",
        "Floors need constant attention",
        "I never clean behind things",
        "Laundry piles up",
        "Surfaces stay sticky",
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: RyddeTheme.Spacing.lg) {
                    backButton

                    VStack(alignment: .leading, spacing: RyddeTheme.Spacing.sm) {
                        Text("What do you struggle\nwith most?")
                            .font(RyddeTheme.Fonts.headingMedium)
                            .foregroundColor(Color(RyddeTheme.Colors.fjord))

                        Text("This helps Rydde prioritize what matters to you.")
                            .font(RyddeTheme.Fonts.body)
                            .foregroundColor(Color(RyddeTheme.Colors.stone))
                    }

                    FlowLayout(spacing: RyddeTheme.Spacing.sm) {
                        ForEach(painPoints, id: \.self) { point in
                            PainPointChip(
                                label: point,
                                isSelected: selectedPainPoints.contains(point),
                                onTap: { togglePainPoint(point) }
                            )
                        }
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(RyddeTheme.Fonts.bodySmall)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, RyddeTheme.Spacing.lg)
                .padding(.top, RyddeTheme.Spacing.md)
            }

            getStartedButton
        }
    }

    private var backButton: some View {
        Button(action: onBack) {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(RyddeTheme.Colors.fjord))
        }
    }

    private var getStartedButton: some View {
        Button(action: onComplete) {
            if isSubmitting {
                ProgressView()
                    .tint(Color(RyddeTheme.Colors.snow))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(RyddeTheme.Colors.moss))
                    .cornerRadius(RyddeTheme.CornerRadius.button)
            } else {
                Text("Get started")
                    .font(RyddeTheme.Fonts.buttonLabel)
                    .foregroundColor(Color(RyddeTheme.Colors.snow))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(RyddeTheme.Colors.moss))
                    .cornerRadius(RyddeTheme.CornerRadius.button)
            }
        }
        .disabled(isSubmitting)
        .padding(.horizontal, RyddeTheme.Spacing.lg)
        .padding(.bottom, RyddeTheme.Spacing.lg)
    }

    private func togglePainPoint(_ point: String) {
        if selectedPainPoints.contains(point) {
            selectedPainPoints.remove(point)
        } else {
            selectedPainPoints.insert(point)
        }
    }
}

private struct PainPointChip: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(RyddeTheme.Fonts.body)
                .foregroundColor(isSelected ? Color(RyddeTheme.Colors.moss) : Color(RyddeTheme.Colors.fjord))
                .padding(.horizontal, RyddeTheme.Spacing.md)
                .padding(.vertical, RyddeTheme.Spacing.sm)
                .background(isSelected ? Color(RyddeTheme.Colors.dew) : Color(RyddeTheme.Colors.frost))
                .cornerRadius(RyddeTheme.CornerRadius.button)
                .overlay(
                    RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.button)
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
