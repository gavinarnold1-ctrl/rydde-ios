import SwiftUI

struct EditPainPointsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State var painPoints: [PainPointItem]
    @State private var newPainPoint = ""
    let onAdd: ([String]) -> Void
    let onDelete: (UUID) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: RyddeTheme.Spacing.sm) {
                        ForEach(painPoints) { point in
                            HStack {
                                Text(point.description)
                                    .font(RyddeTheme.Fonts.body)
                                    .foregroundColor(Color(RyddeTheme.Colors.primaryText))
                                Spacer()
                                Button(action: {
                                    painPoints.removeAll { $0.id == point.id }
                                    onDelete(point.id)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red.opacity(0.7))
                                        .frame(width: 44, height: 44)
                                }
                            }
                            .padding(.horizontal, RyddeTheme.Spacing.md)
                            .padding(.vertical, RyddeTheme.Spacing.xs)
                            .background(Color(RyddeTheme.Colors.cardBackground))
                            .cornerRadius(RyddeTheme.CornerRadius.card)
                        }

                        HStack(spacing: RyddeTheme.Spacing.sm) {
                            TextField("Add a pain point", text: $newPainPoint)
                                .font(RyddeTheme.Fonts.body)
                                .foregroundColor(Color(RyddeTheme.Colors.primaryText))
                                .padding(RyddeTheme.Spacing.md)
                                .background(Color(RyddeTheme.Colors.surface))
                                .cornerRadius(RyddeTheme.CornerRadius.button)
                                .overlay(
                                    RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.button)
                                        .stroke(Color(RyddeTheme.Colors.border), lineWidth: 1)
                                )

                            Button(action: addPainPoint) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(Color(RyddeTheme.Colors.accent))
                                    .frame(width: 44, height: 44)
                            }
                            .disabled(newPainPoint.trimmingCharacters(in: .whitespaces).isEmpty)
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
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Color(RyddeTheme.Colors.primaryText))
                            .frame(width: 44, height: 44)
                    }
                }
            }
        }
    }

    private func addPainPoint() {
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
