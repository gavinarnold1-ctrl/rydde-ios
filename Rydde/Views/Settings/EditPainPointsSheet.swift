import SwiftUI

private let suggestionChips = [
    "Bathroom gets gross fast",
    "Dust builds up everywhere",
    "Kitchen is always messy",
    "Clutter accumulates",
    "Floors need constant attention",
    "I never clean behind things",
    "Laundry piles up",
    "Surfaces stay sticky",
]

struct EditPainPointsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State var painPoints: [PainPointItem]
    @State private var newPainPoint = ""
    let onAdd: ([String]) -> Void
    let onDelete: (UUID) -> Void

    private var selectedDescriptions: Set<String> {
        Set(painPoints.map { $0.description })
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: RyddeTheme.Spacing.lg) {
                        // Suggestion chips
                        VStack(alignment: .leading, spacing: RyddeTheme.Spacing.sm) {
                            Text("SUGGESTIONS")
                                .font(RyddeTheme.Fonts.bodyMedium11)
                                .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                                .kerning(2)

                            FlowLayout(spacing: RyddeTheme.Spacing.sm) {
                                ForEach(suggestionChips, id: \.self) { chip in
                                    let isSelected = selectedDescriptions.contains(chip)
                                    Button(action: { toggleChip(chip) }) {
                                        Text(chip)
                                            .font(RyddeTheme.Fonts.bodySmall)
                                            .foregroundColor(isSelected ? Color(RyddeTheme.Colors.accent) : Color(RyddeTheme.Colors.secondaryText))
                                            .padding(.horizontal, RyddeTheme.Spacing.md)
                                            .padding(.vertical, RyddeTheme.Spacing.sm)
                                            .background(isSelected ? Color(RyddeTheme.Colors.selectedBackground) : Color(RyddeTheme.Colors.surface))
                                            .cornerRadius(RyddeTheme.CornerRadius.button)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.button)
                                                    .stroke(isSelected ? Color(RyddeTheme.Colors.accent) : Color(RyddeTheme.Colors.border), lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Custom pain points
                        VStack(alignment: .leading, spacing: RyddeTheme.Spacing.sm) {
                            Text("CUSTOM")
                                .font(RyddeTheme.Fonts.bodyMedium11)
                                .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                                .kerning(2)

                            let customPoints = painPoints.filter { !suggestionChips.contains($0.description) }
                            ForEach(customPoints) { point in
                                HStack {
                                    Text(point.description)
                                        .font(RyddeTheme.Fonts.body)
                                        .foregroundColor(Color(RyddeTheme.Colors.primaryText))
                                    Spacer()
                                    Button(action: { removePainPoint(point) }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(Color(RyddeTheme.Colors.ember))
                                            .frame(width: 44, height: 44)
                                    }
                                }
                                .padding(.horizontal, RyddeTheme.Spacing.md)
                                .padding(.vertical, RyddeTheme.Spacing.xs)
                                .background(Color(RyddeTheme.Colors.cardBackground))
                                .cornerRadius(RyddeTheme.CornerRadius.card)
                            }

                            HStack(spacing: RyddeTheme.Spacing.sm) {
                                TextField("Add your own", text: $newPainPoint)
                                    .font(RyddeTheme.Fonts.body)
                                    .foregroundColor(Color(RyddeTheme.Colors.primaryText))
                                    .padding(RyddeTheme.Spacing.md)
                                    .background(Color(RyddeTheme.Colors.surface))
                                    .cornerRadius(RyddeTheme.CornerRadius.button)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.button)
                                            .stroke(Color(RyddeTheme.Colors.border), lineWidth: 1)
                                    )
                                Button(action: addCustom) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.custom("DMSans-Regular", size: 28))
                                        .foregroundColor(Color(RyddeTheme.Colors.accent))
                                        .frame(width: 44, height: 44)
                                }
                                .disabled(newPainPoint.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                        }
                    }
                    .padding(RyddeTheme.Spacing.lg)
                }
            }
            .background(Color(RyddeTheme.Colors.background).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Pain points")
                        .font(RyddeTheme.Fonts.headingSmall)
                        .foregroundColor(Color(RyddeTheme.Colors.primaryText))
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.custom("DMSans-Regular", size: 17))
                            .foregroundColor(Color(RyddeTheme.Colors.primaryText))
                            .frame(width: 44, height: 44)
                    }
                }
            }
        }
    }

    private func toggleChip(_ description: String) {
        if let existing = painPoints.first(where: { $0.description == description }) {
            removePainPoint(existing)
        } else {
            onAdd([description])
            painPoints.append(PainPointItem(id: UUID(), description: description))
        }
    }

    private func removePainPoint(_ point: PainPointItem) {
        painPoints.removeAll { $0.id == point.id }
        onDelete(point.id)
    }

    private func addCustom() {
        let text = newPainPoint.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        onAdd([text])
        painPoints.append(PainPointItem(id: UUID(), description: text))
        newPainPoint = ""
    }
}

struct PainPointItem: Identifiable {
    let id: UUID
    let description: String
}

// MARK: - Flow Layout for suggestion chips

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}
