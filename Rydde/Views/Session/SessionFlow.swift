import SwiftUI

struct SessionFlowState: Equatable {
    let durationMinutes: Int
    let id = UUID()

    static func == (lhs: SessionFlowState, rhs: SessionFlowState) -> Bool {
        lhs.id == rhs.id
    }
}

enum SessionPhase: Equatable {
    case loading
    case error(String)
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
    @State private var loadingStartTime: Date?

    var body: some View {
        ZStack {
            Color(RyddeTheme.Colors.background)
                .ignoresSafeArea()

            switch phase {
            case .loading:
                TaskLoadingView()
                    .transition(.opacity)
            case .error(let message):
                TaskErrorView(message: message, onRetry: {
                    phase = .loading
                    Task { await fetchTask() }
                }, onCancel: onDismiss)
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
            await fetchTask()
        }
    }

    private func fetchTask() async {
        loadingStartTime = Date()

        // Start a timeout monitor
        let timeoutTask = Task {
            try await Task.sleep(nanoseconds: 10_000_000_000) // 10s
            if phase == .loading {
                // Show "taking longer" message but keep waiting
            }
            try await Task.sleep(nanoseconds: 5_000_000_000) // another 5s (15s total)
            if phase == .loading {
                phase = .error("Taking longer than usual.\nWant to try again?")
            }
        }

        do {
            let response = try await TaskService.shared.generateTask(
                durationMinutes: state.durationMinutes
            )
            timeoutTask.cancel()
            sessionId = response.sessionId
            generatedTask = response.task
            phase = .active
            startTimer()
        } catch {
            timeoutTask.cancel()
            if phase == .loading {
                phase = .error("Couldn't connect. Check your connection and try again.")
            }
        }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
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

struct UpdateSessionRequest: Encodable {
    let status: String
}

// MARK: - Error View

struct TaskErrorView: View {
    let message: String
    let onRetry: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: RyddeTheme.Spacing.lg) {
            Text(message)
                .font(RyddeTheme.Fonts.bodyDynamic)
                .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                .multilineTextAlignment(.center)

            Button(action: onRetry) {
                Text("Try again")
                    .font(RyddeTheme.Fonts.buttonLabel)
                    .foregroundColor(Color(RyddeTheme.Colors.snow))
                    .frame(width: 200, height: 48)
                    .background(Color(RyddeTheme.Colors.accent))
                    .cornerRadius(RyddeTheme.CornerRadius.button)
            }
            .accessibilityLabel("Retry task generation")

            Button(action: onCancel) {
                Text("Go back")
                    .font(RyddeTheme.Fonts.bodySmall14)
                    .foregroundColor(Color(RyddeTheme.Colors.secondaryText))
                    .frame(minWidth: 44, minHeight: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Cancel and go back")
        }
    }
}
