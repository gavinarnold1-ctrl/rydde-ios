import SwiftUI

private let defaultCatalog: [(String, [String])] = [
    ("Cloths & Wipes", [
        "Microfiber cloths", "Paper towels", "Sponges", "Scrub brush",
        "Old toothbrush", "Lint roller", "Dusting cloths / Swiffer dusters",
    ]),
    ("Sprays & Solutions", [
        "All-purpose cleaner", "Glass cleaner", "Bathroom cleaner",
        "Kitchen degreaser", "Disinfectant spray", "Dish soap",
        "Bar Keepers Friend", "Baking soda", "White vinegar",
        "Bleach", "Wood polish", "Stainless steel cleaner",
    ]),
    ("Floor Tools", [
        "Broom & dustpan", "Vacuum (upright)", "Handheld vacuum",
        "Mop (traditional)", "Swiffer WetJet / spray mop", "Steam mop",
        "Robot vacuum",
    ]),
    ("Equipment", [
        "Squeegee", "Toilet brush", "Plunger", "Rubber gloves",
        "Step stool", "Bucket", "Spray bottles", "Trash bags",
        "Caddy / cleaning tote",
    ]),
    ("Specialty", [
        "Oven cleaner", "Grout brush", "Shower squeegee",
        "Lint trap brush", "Grill brush",
    ]),
]

struct SuppliesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var items: [SupplyItem] = []
    @State private var customInputs: [String: String] = [:] // category -> text
    @State private var isLoading = true
    @State private var saveTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    VStack { Spacer(); ArcSpinner(size: 24); Spacer() }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: RyddeTheme.Spacing.xl) {
                            ForEach(categories, id: \.self) { category in
                                categorySection(category)
                            }
                        }
                        .padding(RyddeTheme.Spacing.lg)
                    }
                }
            }
            .background(Color(RyddeTheme.Colors.background).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Supplies")
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
            .task { await loadSupplies() }
        }
    }

    private var categories: [String] {
        defaultCatalog.map { $0.0 }
    }

    private func categorySection(_ category: String) -> some View {
        VStack(alignment: .leading, spacing: RyddeTheme.Spacing.sm) {
            Text(category.uppercased())
                .font(RyddeTheme.Fonts.bodyMedium11)
                .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                .kerning(2)

            let categoryItems = items.filter { $0.category == category }
            ForEach(Array(categoryItems.enumerated()), id: \.element.name) { _, item in
                supplyRow(item)
            }

            // Custom supply input
            HStack(spacing: RyddeTheme.Spacing.sm) {
                TextField("Add custom", text: binding(for: category))
                    .font(RyddeTheme.Fonts.body)
                    .foregroundColor(Color(RyddeTheme.Colors.primaryText))
                    .padding(RyddeTheme.Spacing.sm)
                    .background(Color(RyddeTheme.Colors.surface))
                    .cornerRadius(RyddeTheme.CornerRadius.button)
                    .overlay(
                        RoundedRectangle(cornerRadius: RyddeTheme.CornerRadius.button)
                            .stroke(Color(RyddeTheme.Colors.border), lineWidth: 1)
                    )
                Button(action: { addCustom(to: category) }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.custom("DMSans-Regular", size: 24))
                        .foregroundColor(Color(RyddeTheme.Colors.accent))
                        .frame(width: 44, height: 44)
                }
                .disabled((customInputs[category] ?? "").trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func supplyRow(_ item: SupplyItem) -> some View {
        HStack {
            Text(item.name)
                .font(RyddeTheme.Fonts.body)
                .foregroundColor(Color(RyddeTheme.Colors.primaryText))
            Spacer()
            Toggle("", isOn: Binding(
                get: { item.active },
                set: { newValue in
                    toggleItem(name: item.name, active: newValue)
                }
            ))
            .tint(Color(RyddeTheme.Colors.accent))
            .labelsHidden()
        }
        .frame(minHeight: 44)
    }

    private func binding(for category: String) -> Binding<String> {
        Binding(
            get: { customInputs[category] ?? "" },
            set: { customInputs[category] = $0 }
        )
    }

    private func toggleItem(name: String, active: Bool) {
        if let idx = items.firstIndex(where: { $0.name == name }) {
            items[idx].active = active
            debounceSave()
        }
    }

    private func addCustom(to category: String) {
        let text = (customInputs[category] ?? "").trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        items.append(SupplyItem(name: text, category: category, isCustom: true, active: true))
        customInputs[category] = ""
        debounceSave()
    }

    private func debounceSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second debounce
            guard !Task.isCancelled else { return }
            await saveSupplies()
        }
    }

    private func loadSupplies() async {
        do {
            let response: SuppliesResponse = try await APIService.shared.get(endpoint: "/api/supplies")
            if response.supplies.isEmpty {
                // First load: pre-populate with default catalog (all inactive)
                items = defaultCatalog.flatMap { (category, names) in
                    names.map { SupplyItem(name: $0, category: category, isCustom: false, active: false) }
                }
            } else {
                // Merge server data with default catalog
                var result: [SupplyItem] = []
                let serverByName = Dictionary(uniqueKeysWithValues: response.supplies.map { ($0.name, $0) })

                for (category, names) in defaultCatalog {
                    for name in names {
                        if let server = serverByName[name] {
                            result.append(SupplyItem(name: name, category: category, isCustom: false, active: server.active))
                        } else {
                            result.append(SupplyItem(name: name, category: category, isCustom: false, active: false))
                        }
                    }
                }
                // Add custom supplies from server
                for supply in response.supplies where supply.isCustom {
                    result.append(SupplyItem(name: supply.name, category: supply.category, isCustom: true, active: supply.active))
                }
                items = result
            }
        } catch {
            // On error, show default catalog
            items = defaultCatalog.flatMap { (category, names) in
                names.map { SupplyItem(name: $0, category: category, isCustom: false, active: false) }
            }
        }
        isLoading = false
    }

    private func saveSupplies() async {
        let activeOrCustom = items.filter { $0.active || $0.isCustom }
        let inputs = activeOrCustom.map {
            SupplyInput(name: $0.name, category: $0.category, active: $0.active, isCustom: $0.isCustom)
        }
        let body = SuppliesRequest(supplies: inputs)
        let _: SuppliesResponse? = try? await APIService.shared.post(endpoint: "/api/supplies", body: body)
    }
}

private struct SupplyItem: Identifiable {
    let name: String
    let category: String
    var isCustom: Bool
    var active: Bool

    var id: String { "\(category)_\(name)" }
}
