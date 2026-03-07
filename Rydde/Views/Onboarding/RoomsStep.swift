import SwiftUI

struct RoomsStep: View {
    let homeType: HomeType
    @Binding var selectedRooms: Set<String>
    var onNext: () -> Void
    var onBack: () -> Void

    @State private var customRoomName = ""
    @State private var isAddingCustomRoom = false
    @State private var availableRooms: [String] = []
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: RyddeTheme.Spacing.lg) {
                    backButton

                    Text("What rooms do you have?")
                        .font(RyddeTheme.Fonts.headingMedium)
                        .foregroundColor(Color(RyddeTheme.Colors.primaryText))

                    FlowLayout(spacing: RyddeTheme.Spacing.sm) {
                        ForEach(availableRooms, id: \.self) { room in
                            RoomChip(
                                label: room,
                                isSelected: selectedRooms.contains(room),
                                onTap: { toggleRoom(room) }
                            )
                        }

                        if isAddingCustomRoom {
                            customRoomInput
                        } else {
                            addRoomChip
                        }
                    }
                }
                .padding(.horizontal, RyddeTheme.Spacing.lg)
                .padding(.top, RyddeTheme.Spacing.md)
            }

            nextButton
        }
        .onAppear {
            if availableRooms.isEmpty {
                availableRooms = homeType.defaultRooms
                selectedRooms = Set(homeType.defaultRooms)
            }
        }
    }

    private var backButton: some View {
        Button(action: onBack) {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(RyddeTheme.Colors.primaryText))
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel("Back")
    }

    private var addRoomChip: some View {
        Button(action: {
            isAddingCustomRoom = true
            isTextFieldFocused = true
        }) {
            Text("+ Add room")
                .font(RyddeTheme.Fonts.body)
                .foregroundColor(Color(RyddeTheme.Colors.accent))
                .padding(.horizontal, RyddeTheme.Spacing.md)
                .padding(.vertical, RyddeTheme.Spacing.sm)
                .background(Color(RyddeTheme.Colors.cardBackground))
                .cornerRadius(RyddeTheme.CornerRadius.button)
                .overlay(
                    RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.button)
                        .stroke(Color(RyddeTheme.Colors.border), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }

    private var customRoomInput: some View {
        HStack(spacing: RyddeTheme.Spacing.xs) {
            TextField("Room name", text: $customRoomName)
                .font(RyddeTheme.Fonts.body)
                .foregroundColor(Color(RyddeTheme.Colors.primaryText))
                .focused($isTextFieldFocused)
                .onSubmit { addCustomRoom() }
                .submitLabel(.done)

            Button(action: addCustomRoom) {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(RyddeTheme.Colors.accent))
                    .frame(width: 44, height: 44)
            }
            .disabled(customRoomName.trimmingCharacters(in: .whitespaces).isEmpty)
            .accessibilityLabel("Confirm room name")

            Button(action: {
                isAddingCustomRoom = false
                customRoomName = ""
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Cancel adding room")
        }
        .padding(.horizontal, RyddeTheme.Spacing.md)
        .padding(.vertical, RyddeTheme.Spacing.sm)
        .background(Color(RyddeTheme.Colors.cardBackground))
        .cornerRadius(RyddeTheme.CornerRadius.button)
        .overlay(
            RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.button)
                .stroke(Color(RyddeTheme.Colors.accent), lineWidth: 1)
        )
        .frame(width: 200)
    }

    private var nextButton: some View {
        Button(action: onNext) {
            Text("Next")
                .font(RyddeTheme.Fonts.buttonLabel)
                .foregroundColor(Color(RyddeTheme.Colors.snow))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color(RyddeTheme.Colors.accent))
                .cornerRadius(RyddeTheme.CornerRadius.button)
        }
        .disabled(selectedRooms.isEmpty)
        .opacity(selectedRooms.isEmpty ? 0.4 : 1.0)
        .padding(.horizontal, RyddeTheme.Spacing.lg)
        .padding(.bottom, RyddeTheme.Spacing.lg)
        .accessibilityLabel("Next step")
    }

    private func toggleRoom(_ room: String) {
        if selectedRooms.contains(room) {
            selectedRooms.remove(room)
        } else {
            selectedRooms.insert(room)
        }
    }

    private func addCustomRoom() {
        let name = customRoomName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        availableRooms.append(name)
        selectedRooms.insert(name)
        customRoomName = ""
        isAddingCustomRoom = false
    }
}

private struct RoomChip: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(RyddeTheme.Fonts.body)
                .foregroundColor(isSelected ? Color(RyddeTheme.Colors.accent) : Color(RyddeTheme.Colors.primaryText))
                .padding(.horizontal, RyddeTheme.Spacing.md)
                .padding(.vertical, RyddeTheme.Spacing.sm)
                .background(isSelected ? Color(RyddeTheme.Colors.selectedBackground) : Color(RyddeTheme.Colors.cardBackground))
                .cornerRadius(RyddeTheme.CornerRadius.button)
                .overlay(
                    RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.button)
                        .stroke(
                            isSelected ? Color(RyddeTheme.Colors.accent) : Color(RyddeTheme.Colors.border),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .animation(.easeOut(duration: 0.3), value: isSelected)
    }
}
