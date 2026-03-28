import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RyddeTheme.Spacing.xl) {
                    yourHomeSection
                    householdSection
                    automationSection
                    accountSection
                    aboutSection
                }
                .padding(.horizontal, RyddeTheme.Spacing.lg)
                .padding(.vertical, RyddeTheme.Spacing.lg)
            }
            .background(Color(RyddeTheme.Colors.background).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) { Text("Settings").font(RyddeTheme.Fonts.headingSmall).foregroundColor(Color(RyddeTheme.Colors.primaryText)) }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) { Image(systemName: "chevron.left").font(.system(size: 17, weight: .medium)).foregroundColor(Color(RyddeTheme.Colors.primaryText)).frame(width: 44, height: 44) }
                    .accessibilityLabel("Close settings")
                }
            }
            .task { await viewModel.load() }
            .sheet(isPresented: $viewModel.showEditHome) {
                EditHomeSheet(homeType: $viewModel.homeType) { type in Task { await viewModel.updateHomeType(type) } }
            }
            .sheet(isPresented: $viewModel.showEditRooms) {
                EditRoomsSheet(rooms: viewModel.roomNames) { rooms in Task { await viewModel.updateRooms(rooms) } }
            }
            .sheet(isPresented: $viewModel.showEditPainPoints) {
                EditPainPointsSheet(painPoints: viewModel.painPointItems, onAdd: { descriptions in Task { await viewModel.addPainPoints(descriptions) } }, onDelete: { id in Task { await viewModel.deletePainPoint(id) } })
            }
            .sheet(isPresented: $viewModel.showSupplies) {
                SuppliesView()
            }
        }
    }

    private var yourHomeSection: some View {
        SettingsSection(title: "YOUR HOME") {
            Button(action: { viewModel.showEditHome = true }) {
                SettingsRow(label: "Home type", value: viewModel.homeType?.label ?? "\u{2014}")
            }.buttonStyle(.plain)
            Button(action: { viewModel.showEditRooms = true }) {
                SettingsRow(label: "Rooms", value: "\(viewModel.roomCount) rooms")
            }.buttonStyle(.plain)
            Button(action: { viewModel.showEditPainPoints = true }) {
                SettingsRow(label: "Pain points", value: "\(viewModel.painPointCount) selected")
            }.buttonStyle(.plain)
            Button(action: { viewModel.showSupplies = true }) {
                SettingsRow(label: "Supplies", value: "Manage inventory")
            }.buttonStyle(.plain)
        }
    }

    private var householdSection: some View {
        SettingsSection(title: "HOUSEHOLD") {
            if viewModel.householdMembers.isEmpty { soloHouseholdContent } else { memberListContent }
            Divider().foregroundColor(Color(RyddeTheme.Colors.border))
            joinHouseholdContent
        }
    }

    private var soloHouseholdContent: some View {
        VStack(alignment: .leading, spacing: RyddeTheme.Spacing.md) {
            if let code = viewModel.inviteCode {
                VStack(alignment: .leading, spacing: RyddeTheme.Spacing.sm) {
                    Text("Invite someone").font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.primaryText))
                    HStack {
                        Text(code).font(RyddeTheme.Fonts.headingMedium).foregroundColor(Color(RyddeTheme.Colors.primaryText)).textSelection(.enabled)
                        Spacer()
                        Button(action: { viewModel.copyInviteCode() }) { Image(systemName: "doc.on.doc").font(.system(size: 16)).foregroundColor(Color(RyddeTheme.Colors.accent)).frame(width: 44, height: 44) }.accessibilityLabel("Copy invite code")
                        Button(action: { viewModel.showShareSheet = true }) { Image(systemName: "square.and.arrow.up").font(.system(size: 16)).foregroundColor(Color(RyddeTheme.Colors.accent)).frame(width: 44, height: 44) }.accessibilityLabel("Share invite code")
                    }
                    .padding(RyddeTheme.Spacing.md).background(Color(RyddeTheme.Colors.surface)).cornerRadius(RyddeTheme.CornerRadius.card)
                    .overlay(RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.card).stroke(Color(RyddeTheme.Colors.border), lineWidth: 1))
                }
            } else {
                Button(action: { Task { await viewModel.generateInviteCode() } }) { Text("Invite someone").font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.accent)).frame(minHeight: 44) }
            }
        }
        .sheet(isPresented: $viewModel.showShareSheet) { if let code = viewModel.inviteCode { ShareSheet(items: ["Join my household on Rydde! Use code: \(code)"]) } }
    }

    private var memberListContent: some View {
        VStack(alignment: .leading, spacing: RyddeTheme.Spacing.sm) {
            ForEach(viewModel.householdMembers) { member in
                HStack {
                    Text(member.displayName).font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.primaryText))
                    Spacer()
                    Text(member.joinedLabel).font(.custom("DMSans-Regular", size: 12)).foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                }.accessibilityElement(children: .combine)
            }
            if let code = viewModel.inviteCode {
                HStack {
                    Text("Invite code:").font(RyddeTheme.Fonts.bodySmall).foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                    Text(code).font(RyddeTheme.Fonts.bodyMedium).foregroundColor(Color(RyddeTheme.Colors.primaryText)).textSelection(.enabled)
                    Spacer()
                    Button(action: { viewModel.showShareSheet = true }) { Image(systemName: "square.and.arrow.up").font(.system(size: 14)).foregroundColor(Color(RyddeTheme.Colors.accent)).frame(width: 44, height: 44) }.accessibilityLabel("Share invite code")
                }.padding(.top, RyddeTheme.Spacing.xs)
            }
        }
        .sheet(isPresented: $viewModel.showShareSheet) { if let code = viewModel.inviteCode { ShareSheet(items: ["Join my household on Rydde! Use code: \(code)"]) } }
    }

    private var joinHouseholdContent: some View {
        VStack(alignment: .leading, spacing: RyddeTheme.Spacing.sm) {
            Text("Join a household").font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.primaryText))
            HStack(spacing: RyddeTheme.Spacing.sm) {
                TextField("Enter code", text: $viewModel.joinCode)
                    .font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.primaryText))
                    .padding(RyddeTheme.Spacing.sm).background(Color(RyddeTheme.Colors.surface)).cornerRadius(RyddeTheme.CornerRadius.button)
                    .overlay(RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.button).stroke(Color(RyddeTheme.Colors.border), lineWidth: 1))
                Button(action: { Task { await viewModel.joinHousehold() } }) {
                    Text("Join").font(RyddeTheme.Fonts.buttonLabel).foregroundColor(Color(RyddeTheme.Colors.snow)).padding(.horizontal, RyddeTheme.Spacing.md).frame(height: 44).background(Color(RyddeTheme.Colors.accent)).cornerRadius(RyddeTheme.CornerRadius.button)
                }
                .disabled(viewModel.joinCode.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(viewModel.joinCode.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1.0)
            }
            if let error = viewModel.joinError { Text(error).font(RyddeTheme.Fonts.bodySmall).foregroundColor(.red) }
        }
    }

    private var automationSection: some View {
        SettingsSection(title: "AUTOMATION") {
            Toggle(isOn: $viewModel.reminderEnabled) {
                Text("Daily reminder").font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.primaryText))
            }
            .tint(Color(RyddeTheme.Colors.accent))
            .onChange(of: viewModel.reminderEnabled) { _, enabled in
                if enabled { Task { await viewModel.onReminderEnabled() } } else { Task { await viewModel.saveAutomation() } }
            }
            if viewModel.reminderEnabled {
                VStack(alignment: .leading, spacing: RyddeTheme.Spacing.md) {
                    DatePicker("Time", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                        .font(RyddeTheme.Fonts.body).tint(Color(RyddeTheme.Colors.accent))
                        .onChange(of: viewModel.reminderTime) { _, _ in Task { await viewModel.saveAutomation() } }
                    VStack(alignment: .leading, spacing: RyddeTheme.Spacing.sm) {
                        Text("Duration").font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.primaryText))
                        HStack(spacing: RyddeTheme.Spacing.sm) {
                            ForEach([10, 15, 30, 60], id: \.self) { mins in
                                DurationChip(label: mins >= 60 ? "1 hr" : "\(mins) min", isSelected: viewModel.reminderDuration == mins) {
                                    viewModel.reminderDuration = mins; Task { await viewModel.saveAutomation() }
                                }
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: RyddeTheme.Spacing.sm) {
                        Text("Days").font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.primaryText))
                        HStack(spacing: RyddeTheme.Spacing.sm) {
                            ForEach(DayOfWeek.allCases) { day in
                                DayCircle(day: day, isSelected: viewModel.reminderDays.contains(day)) { viewModel.toggleDay(day); Task { await viewModel.saveAutomation() } }
                            }
                        }
                    }
                }.padding(.top, RyddeTheme.Spacing.sm).animation(.easeOut(duration: 0.3), value: viewModel.reminderEnabled)
            }
        }
    }

    private var accountSection: some View {
        SettingsSection(title: "ACCOUNT") {
            HStack {
                Text("Display name").font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.primaryText))
                Spacer()
                TextField("Name", text: $viewModel.displayName).font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.primaryText)).multilineTextAlignment(.trailing).onSubmit { Task { await viewModel.updateDisplayName() } }
            }

            VStack(alignment: .leading, spacing: RyddeTheme.Spacing.sm) {
                Text("Appearance").font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.primaryText))
                Picker("Appearance", selection: $viewModel.appearanceMode) {
                    Text("Light").tag(AppearanceMode.light)
                    Text("Dark").tag(AppearanceMode.dark)
                    Text("System").tag(AppearanceMode.system)
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.appearanceMode) { _, mode in
                    viewModel.saveAppearance(mode)
                }
            }

            Button(action: { authService.signOut() }) { Text("Sign out").font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.ember)).frame(minHeight: 44) }.accessibilityLabel("Sign out of your account")
        }
    }

    private var aboutSection: some View {
        SettingsSection(title: "ABOUT") {
            Text("rydde v1.0").font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.primaryText))
            Text("an oversikt product").font(RyddeTheme.Fonts.bodySmall).foregroundColor(Color(RyddeTheme.Colors.secondaryText))
            Link("Privacy Policy", destination: URL(string: "https://rydde.app/privacy")!).font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.accent))
            Link("Terms of Service", destination: URL(string: "https://rydde.app/terms")!).font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.accent))
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: RyddeTheme.Spacing.md) {
            Text(title).font(RyddeTheme.Fonts.bodyMedium11).foregroundColor(Color(RyddeTheme.Colors.secondaryText)).kerning(2)
            VStack(alignment: .leading, spacing: RyddeTheme.Spacing.md) { content() }
                .padding(RyddeTheme.Spacing.md).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(RyddeTheme.Colors.cardBackground)).cornerRadius(RyddeTheme.CornerRadius.card)
                .overlay(RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.card).stroke(Color(RyddeTheme.Colors.border), lineWidth: 1))
        }
    }
}

struct SettingsRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label).font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.primaryText))
            Spacer()
            Text(value).font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.secondaryText))
            Image(systemName: "chevron.right").font(.system(size: 12, weight: .medium)).foregroundColor(Color(RyddeTheme.Colors.border))
        }.frame(minHeight: 44).accessibilityElement(children: .combine)
    }
}

private struct DurationChip: View {
    let label: String; let isSelected: Bool; let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            Text(label).font(RyddeTheme.Fonts.bodySmall)
                .foregroundColor(isSelected ? Color(RyddeTheme.Colors.accent) : Color(RyddeTheme.Colors.secondaryText))
                .padding(.horizontal, RyddeTheme.Spacing.sm + 2).padding(.vertical, RyddeTheme.Spacing.xs + 2)
                .background(isSelected ? Color(RyddeTheme.Colors.selectedBackground) : Color(RyddeTheme.Colors.surface))
                .cornerRadius(RyddeTheme.CornerRadius.button)
                .overlay(RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.button).stroke(isSelected ? Color(RyddeTheme.Colors.accent) : Color(RyddeTheme.Colors.border), lineWidth: 1))
        }.buttonStyle(.plain).frame(minHeight: 44)
    }
}

private struct DayCircle: View {
    let day: DayOfWeek; let isSelected: Bool; let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            Text(day.shortLabel).font(RyddeTheme.Fonts.bodySmall)
                .foregroundColor(isSelected ? Color(RyddeTheme.Colors.snow) : Color(RyddeTheme.Colors.secondaryText))
                .frame(width: 44, height: 44)
                .background(isSelected ? Color(RyddeTheme.Colors.accent) : Color(RyddeTheme.Colors.surface))
                .clipShape(Circle())
                .overlay(Circle().stroke(isSelected ? Color(RyddeTheme.Colors.accent) : Color(RyddeTheme.Colors.border), lineWidth: 1))
        }.buttonStyle(.plain).accessibilityLabel("\(day.rawValue), \(isSelected ? "selected" : "not selected")")
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController { UIActivityViewController(activityItems: items, applicationActivities: nil) }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
