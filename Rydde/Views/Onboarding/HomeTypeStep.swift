import SwiftUI

struct HomeTypeStep: View {
    @Binding var selectedType: HomeType?
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: RyddeTheme.Spacing.lg) {
                    Text("What kind of space\ndo you live in?")
                        .font(RyddeTheme.Fonts.headingMedium)
                        .foregroundColor(Color(RyddeTheme.Colors.fjord))
                        .padding(.top, RyddeTheme.Spacing.xl)

                    VStack(spacing: RyddeTheme.Spacing.sm) {
                        ForEach(HomeType.allCases) { type in
                            HomeTypeCard(
                                type: type,
                                isSelected: selectedType == type,
                                onTap: { selectedType = type }
                            )
                        }
                    }
                }
                .padding(.horizontal, RyddeTheme.Spacing.lg)
            }

            nextButton
        }
    }

    private var nextButton: some View {
        Button(action: onNext) {
            Text("Next")
                .font(RyddeTheme.Fonts.buttonLabel)
                .foregroundColor(Color(RyddeTheme.Colors.snow))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color(RyddeTheme.Colors.moss))
                .cornerRadius(RyddeTheme.CornerRadius.button)
        }
        .disabled(selectedType == nil)
        .opacity(selectedType == nil ? 0.4 : 1.0)
        .padding(.horizontal, RyddeTheme.Spacing.lg)
        .padding(.bottom, RyddeTheme.Spacing.lg)
    }
}

private struct HomeTypeCard: View {
    let type: HomeType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(type.label)
                .font(RyddeTheme.Fonts.bodyMedium)
                .foregroundColor(Color(RyddeTheme.Colors.fjord))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(RyddeTheme.Spacing.md)
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
