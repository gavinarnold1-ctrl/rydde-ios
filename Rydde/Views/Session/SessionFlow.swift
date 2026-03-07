import SwiftUI

struct SessionFlowState: Equatable {
    let durationMinutes: Int
    let id = UUID()

    static func == (lhs: SessionFlowState, rhs: SessionFlowState) -> Bool {
        lhs.id == rhs.id
    }
}

enum SessionPhase {
    case loading
    case active
    case completed
}

struct SessionFlow: View {
    let state: SessionFlowState
    let onDismiss: () -> Void

    @State private var phase: SessionPhase = .loading
    @State private var generatedTask: GeneratedTask?
    @State private var sessionId: UUID?
    @State private var timerSeconds = 0
    @State private var completedTaskTitle: String?

    var body: some View {
        ZStack {
            Color(RyddeTheme.Colors.snow)
                .ignoresSafeArea()

            switch phase {
            case .loading:
                TaskLoadingView()
                    .transition(.opacity)
            case .active:
                if let task = generatedTask {
                    TaskScreen(
                        task: task,
                        timerSeconds: timerSeconds,
                        onDone: { handleDone(task: task) },
                        onSkip: handleSkip
                    )
                    .transition(.asymmetric(
                        insertion: .offset(y: 20).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            case .completed:
                CompletionView(
                    taskTitle: completedTaskTitle ?? "",
                    onDismiss: onDismiss
                )
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.3), value: phase)
        .task {
            await startSession()
        }
    }

    private func startSession() async {
        // Create session record via API
        let body = CreateSessionRequest(durationMinutes: state.durationMinutes)
        if let response: Session = try? await APIService.shared.post(
            endpoint: "/api/sessions",
            body: body
        ) {
            sessionId = response.id
        }

        // Generate task (mock for now)
        let task = await TaskService.shared.generateTask(durationMinutes: state.durationMinutes)
        generatedTask = task
        phase = .active
        startTimer()
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            timerSeconds += 1
        }
    }

    private func handleDone(task: GeneratedTask) {
        completedTaskTitle = task.title

        if let sessionId {
            Task {
                let body = UpdateSessionRequest(status: "done")
                let _: Session? = try? await APIService.shared.patch(
                    endpoint: "/api/sessions/\(sessionId.uuidString)",
                    body: body
                )
            }
        }

        phase = .completed
    }

    private func handleSkip() {
        if let sessionId {
            Task {
                let body = UpdateSessionRequest(status: "skipped")
                let _: Session? = try? await APIService.shared.patch(
                    endpoint: "/api/sessions/\(sessionId.uuidString)",
                    body: body
                )
            }
        }

        onDismiss()
    }
}

// MARK: - API Types

struct CreateSessionRequest: Encodable {
    let durationMinutes: Int
}

struct UpdateSessionRequest: Encodable {
    let status: String
}
