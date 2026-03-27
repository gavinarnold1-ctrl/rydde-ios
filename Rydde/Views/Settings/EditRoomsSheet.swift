import SwiftUI

struct EditRoomsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State var rooms: [String]
    @State private var newRoom = ""
    let onSave: ([String]) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: RyddeTheme.Spacing.sm) {
                        ForEach(Array(rooms.enumerated()), id: \.offset) { index, room in
                            HStack {
                                Text(room).font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.primaryText))
                                Spacer()
                                Button(action: { rooms.remove(at: index) }) {
                                    Image(systemName: "minus.circle.fill").foregroundColor(.red.opacity(0.7)).frame(width: 44, height: 44)
                                }
                            }
                            .padding(.horizontal, RyddeTheme.Spacing.md).padding(.vertical, RyddeTheme.Spacing.xs)
                            .background(Color(RyddeTheme.Colors.cardBackground)).cornerRadius(RyddeTheme.CornerRadius.card)
                        }
                        HStack(spacing: RyddeTheme.Spacing.sm) {
                            TextField("Add a room", text: $newRoom)
                                .font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.primaryText))
                                .padding(RyddeTheme.Spacing.md).background(Color(RyddeTheme.Colors.surface)).cornerRadius(RyddeTheme.CornerRadius.button)
                                .overlay(RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.button).stroke(Color(RyddeTheme.Colors.border), lineWidth: 1))
                            Button(action: { let name = newRoom.trimmingCharacters(in: .whitespaces); guard !name.isEmpty else { return }; rooms.append(name); newRoom = "" }) {
                                Image(systemName: "plus.circle.fill").font(.system(size: 28)).foregroundColor(Color(RyddeTheme.Colors.accent)).frame(width: 44, height: 44)
                            }
                            .disabled(newRoom.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                    .padding(RyddeTheme.Spacing.lg)
                }
                Button(action: { onSave(rooms); dismiss() }) {
                    Text("Save").font(RyddeTheme.Fonts.buttonLabel).foregroundColor(Color(RyddeTheme.Colors.snow)).frame(maxWidth: .infinity).frame(height: 48).background(Color(RyddeTheme.Colors.accent)).cornerRadius(RyddeTheme.CornerRadius.button)
                }
                .padding(RyddeTheme.Spacing.lg)
            }
            .background(Color(RyddeTheme.Colors.background).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) { Text("Rooms").font(RyddeTheme.Fonts.headingSmall).foregroundColor(Color(RyddeTheme.Colors.primaryText)) }
                ToolbarItem(placement: .topBarLeading) { Button(action: { dismiss() }) { Image(systemName: "xmark").font(.system(size: 17, weight: .medium)).foregroundColor(Color(RyddeTheme.Colors.primaryText)).frame(width: 44, height: 44) } }
            }
        }
    }
}
