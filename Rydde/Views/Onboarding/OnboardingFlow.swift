import SwiftUI

struct OnboardingFlow: View {
    @State private var currentStep = 0
    @State private var homeType: HomeType?
    @State private var selectedRooms: Set<String> = []
    @State private var selectedPainPoints: Set<String> = []
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    var onComplete: () -> Void

    private let totalSteps = 3

    var body: some View {
        VStack(spacing: 0) {
            progressBar
            stepContent
        }
        .background(Color(RyddeTheme.Colors.snow).ignoresSafeArea())
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(RyddeTheme.Colors.sage))
                    .frame(height: 2)

                Rectangle()
                    .fill(Color(RyddeTheme.Colors.moss))
                    .frame(width: geometry.size.width * CGFloat(currentStep + 1) / CGFloat(totalSteps), height: 2)
                    .animation(.easeOut(duration: 0.3), value: currentStep)
            }
        }
        .frame(height: 2)
    }

    // MARK: - Step Content

    private var stepContent: some View {
        ZStack {
            HomeTypeStep(selectedType: $homeType, onNext: goToRooms)
                .offset(x: offsetForStep(0))
                .opacity(currentStep == 0 ? 1 : 0)

            RoomsStep(
                homeType: homeType ?? .apartment,
                selectedRooms: $selectedRooms,
                onNext: goToPainPoints,
                onBack: goBack
            )
            .offset(x: offsetForStep(1))
            .opacity(currentStep == 1 ? 1 : 0)

            PainPointsStep(
                selectedPainPoints: $selectedPainPoints,
                isSubmitting: isSubmitting,
                errorMessage: errorMessage,
                onComplete: submit,
                onBack: goBack
            )
            .offset(x: offsetForStep(2))
            .opacity(currentStep == 2 ? 1 : 0)
        }
        .animation(.easeOut(duration: 0.3), value: currentStep)
    }

    private func offsetForStep(_ step: Int) -> CGFloat {
        let diff = step - currentStep
        return CGFloat(diff) * UIScreen.main.bounds.width
    }

    // MARK: - Navigation

    private func goToRooms() {
        currentStep = 1
    }

    private func goToPainPoints() {
        currentStep = 2
    }

    private func goBack() {
        currentStep = max(0, currentStep - 1)
    }

    // MARK: - Submission

    private func submit() {
        guard !isSubmitting else { return }
        isSubmitting = true
        errorMessage = nil

        Task {
            do {
                let householdBody = CreateHouseholdRequest(
                    name: "\(homeType?.rawValue.capitalized ?? "My") Home"
                )
                let household: Household = try await APIService.shared.post(
                    endpoint: "/api/households",
                    body: householdBody
                )

                let spaceBody = CreateSpaceRequest(
                    householdId: household.id,
                    name: homeType?.rawValue.capitalized ?? "Home",
                    rooms: Array(selectedRooms)
                )
                let _: CreateSpaceResponse = try await APIService.shared.post(
                    endpoint: "/api/spaces",
                    body: spaceBody
                )

                if !selectedPainPoints.isEmpty {
                    let painPointsBody = CreatePainPointsRequest(
                        householdId: household.id,
                        descriptions: Array(selectedPainPoints)
                    )
                    let _: CreatePainPointsResponse = try await APIService.shared.post(
                        endpoint: "/api/pain-points",
                        body: painPointsBody
                    )
                }

                onComplete()
            } catch {
                errorMessage = error.localizedDescription
                isSubmitting = false
            }
        }
    }
}

// MARK: - API Request/Response Types

struct CreateHouseholdRequest: Encodable {
    let name: String
}

struct CreateSpaceRequest: Encodable {
    let householdId: UUID
    let name: String
    let rooms: [String]
}

struct CreateSpaceResponse: Decodable {
    let space: Space
    let rooms: [Room]
}

struct CreatePainPointsRequest: Encodable {
    let householdId: UUID
    let descriptions: [String]
}

struct CreatePainPointsResponse: Decodable {
    let painPoints: [PainPoint]
}
