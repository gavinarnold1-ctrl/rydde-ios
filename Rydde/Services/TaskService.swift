import Foundation

struct GeneratedTask: Codable {
    let id: UUID
    let room: String
    let title: String
    let description: String
    let rationale: String
    let difficulty: String
}

struct GenerateTaskRequest: Encodable {
    let durationMinutes: Int
    let clientHour: Int
}

struct GenerateTaskResponse: Decodable {
    let sessionId: UUID
    let task: GeneratedTask
}

final class TaskService {
    static let shared = TaskService()

    private init() {}

    func generateTask(durationMinutes: Int) async throws -> GenerateTaskResponse {
        let body = GenerateTaskRequest(
            durationMinutes: durationMinutes,
            clientHour: Calendar.current.component(.hour, from: Date())
        )
        return try await APIService.shared.post(
            endpoint: "/api/generate-task",
            body: body
        )
    }
}
