import SwiftUI

struct EditHomeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var homeType: HomeType?
    let onSave: (HomeType) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RyddeTheme.Spacing.md) {
                    ForEach(HomeType.allCases) { type in
                        Button(action: {
                            homeType = type
                            onSave(type)
                            dismiss()
                        }) {
                            HStack {
                                Text(type.label)
                                    .font(RyddeTheme.Fonts.body)
                                    .foregroundColor(Color(RyddeTheme.Colors.primaryText))
                                Spacer()
                                if homeType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(RyddeTheme.Colors.accent))
                                }
                            }
                            .padding(RyddeTheme.Spacing.md)
                            .background(Color(RyddeTheme.Colors.cardBackground))
                            .cornerRadius(RyddeTheme.CornerRadius.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.card)
                                    .stroke(
                                        homeType == type ? Color(RyddeTheme.Colors.accent) : Color(RyddeTheme.Colors.border),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(RyddeTheme.Spacing.lg)
            }
            .background(Color(RyddeTheme.Colors.background).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Home type")
                        .font(RyddeTheme.Fonts.headingSmall)
                        .foregroundColor(Color(RyddeTheme.Colors.primaryText))
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Color(RyddeTheme.Colors.primaryText))
                            .frame(width: 44, height: 44)
                    }
                }
            }
        }
    }
}
