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

    var body: some View {
        ZStack {
            Color(RyddeTheme.Colors.snow)
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
        do {
            let response = try await TaskService.shared.generateTask(
                durationMinutes: state.durationMinutes
            )
            sessionId = response.sessionId
            generatedTask = response.task
            phase = .active
            startTimer()
        } catch {
            phase = .error("Couldn't generate a task right now.\nTry again?")
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
                .font(RyddeTheme.Fonts.body)
                .foregroundColor(Color(RyddeTheme.Colors.stone))
                .multilineTextAlignment(.center)

            Button(action: onRetry) {
                Text("Try again")
                    .font(RyddeTheme.Fonts.buttonLabel)
                    .foregroundColor(Color(RyddeTheme.Colors.snow))
                    .frame(width: 200, height: 48)
                    .background(Color(RyddeTheme.Colors.moss))
                    .cornerRadius(RyddeTheme.CornerRadius.button)
            }

            Button(action: onCancel) {
                Text("Go back")
                    .font(RyddeTheme.Fonts.bodySmall14)
                    .foregroundColor(Color(RyddeTheme.Colors.stone))
            }
            .buttonStyle(.plain)
        }
    }
}
