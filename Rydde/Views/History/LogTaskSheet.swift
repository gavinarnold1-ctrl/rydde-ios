import SwiftUI

struct LogTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var selectedRoom: RoomOption?
    @State private var completedAt = Date()
    @State private var rooms: [RoomOption] = []
    @State private var isSaving = false
    @State private var errorMessage: String?

    let onSaved: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: RyddeTheme.Spacing.lg) {
                    VStack(alignment: .leading, spacing: RyddeTheme.Spacing.sm) {
                        Text("Room")
                            .font(RyddeTheme.Fonts.bodyMedium11)
                            .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                            .kerning(2)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: RyddeTheme.Spacing.sm) {
                                ForEach(rooms) { room in
                                    Button(action: { selectedRoom = room }) {
                                        Text(room.name)
                                            .font(RyddeTheme.Fonts.bodySmall)
                                            .foregroundColor(selectedRoom?.id == room.id ? Color(RyddeTheme.Colors.accent) : Color(RyddeTheme.Colors.secondaryText))
                                            .padding(.horizontal, RyddeTheme.Spacing.md)
                                            .padding(.vertical, RyddeTheme.Spacing.sm)
                                            .background(selectedRoom?.id == room.id ? Color(RyddeTheme.Colors.selectedBackground) : Color(RyddeTheme.Colors.surface))
                                            .cornerRadius(RyddeTheme.CornerRadius.button)
                                            .overlay(RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.button).stroke(selectedRoom?.id == room.id ? Color(RyddeTheme.Colors.accent) : Color(RyddeTheme.Colors.border), lineWidth: 1))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: RyddeTheme.Spacing.sm) {
                        Text("What did you clean?")
                            .font(RyddeTheme.Fonts.bodyMedium11)
                            .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                            .kerning(2)

                        TextField("e.g. Wiped down kitchen counters", text: $title)
                            .font(RyddeTheme.Fonts.body)
                            .foregroundColor(Color(RyddeTheme.Colors.primaryText))
                            .padding(RyddeTheme.Spacing.md)
                            .background(Color(RyddeTheme.Colors.surface))
                            .cornerRadius(RyddeTheme.CornerRadius.button)
                            .overlay(RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.button).stroke(Color(RyddeTheme.Colors.border), lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: RyddeTheme.Spacing.sm) {
                        Text("Details (optional)")
                            .font(RyddeTheme.Fonts.bodyMedium11)
                            .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                            .kerning(2)

                        TextField("Any notes...", text: $description, axis: .vertical)
                            .font(RyddeTheme.Fonts.body)
                            .foregroundColor(Color(RyddeTheme.Colors.primaryText))
                            .lineLimit(3...6)
                            .padding(RyddeTheme.Spacing.md)
                            .background(Color(RyddeTheme.Colors.surface))
                            .cornerRadius(RyddeTheme.CornerRadius.button)
                            .overlay(RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.button).stroke(Color(RyddeTheme.Colors.border), lineWidth: 1))
                    }

                    DatePicker("When", selection: $completedAt, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                        .font(RyddeTheme.Fonts.body)
                        .foregroundColor(Color(RyddeTheme.Colors.primaryText))
                        .tint(Color(RyddeTheme.Colors.accent))

                    if let error = errorMessage {
                        Text(error).font(RyddeTheme.Fonts.bodySmall).foregroundColor(.red)
                    }

                    Button(action: save) {
                        Text(isSaving ? "Saving..." : "Save")
                            .font(RyddeTheme.Fonts.buttonLabel)
                            .foregroundColor(Color(RyddeTheme.Colors.snow))
                            .frame(maxWidth: .infinity).frame(height: 48)
                            .background(Color(RyddeTheme.Colors.accent))
                            .cornerRadius(RyddeTheme.CornerRadius.button)
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                    .opacity(title.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1.0)
                }
                .padding(.horizontal, RyddeTheme.Spacing.lg)
                .padding(.vertical, RyddeTheme.Spacing.lg)
            }
            .background(Color(RyddeTheme.Colors.background).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) { Text("Log a task").font(RyddeTheme.Fonts.headingSmall).foregroundColor(Color(RyddeTheme.Colors.primaryText)) }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) { Image(systemName: "xmark").font(.system(size: 17, weight: .medium)).foregroundColor(Color(RyddeTheme.Colors.primaryText)).frame(width: 44, height: 44) }
                }
            }
            .task { await loadRooms() }
        }
    }

    private func loadRooms() async {
        do {
            let response: HouseholdDetailResponse = try await APIService.shared.get(endpoint: "/api/households/me")
            rooms = (response.rooms ?? []).map { RoomOption(id: $0.id, name: $0.name) }
        } catch {}
    }

    private func save() {
        guard !isSaving else { return }
        isSaving = true
        errorMessage = nil
        Task {
            do {
                let body = LogTaskRequest(roomId: selectedRoom?.id, title: title.trimmingCharacters(in: .whitespaces), description: description.trimmingCharacters(in: .whitespaces).isEmpty ? nil : description, completedAt: completedAt)
                let _: LogTaskResponse = try await APIService.shared.post(endpoint: "/api/tasks/log", body: body)
                onSaved()
                dismiss()
            } catch {
                errorMessage = "Couldn't save. Try again."
                isSaving = false
            }
        }
    }
}

struct RoomOption: Identifiable {
    let id: UUID
    let name: String
}

struct LogTaskRequest: Encodable {
    let roomId: UUID?
    let title: String
    let description: String?
    let completedAt: Date
}

struct LogTaskResponse: Decodable {
    let task: TaskEntry
}
