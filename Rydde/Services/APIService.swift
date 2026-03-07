import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingError(Error)
    case encodingError(Error)
    case unauthorized
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response from server"
        case .httpError(let code, _): return "HTTP error \(code)"
        case .decodingError(let error): return "Decoding error: \(error.localizedDescription)"
        case .encodingError(let error): return "Encoding error: \(error.localizedDescription)"
        case .unauthorized: return "Unauthorized"
        case .unknown(let error): return error.localizedDescription
        }
    }
}

final class APIService {
    static let shared = APIService()

    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        self.baseURL = Config.apiBaseURL
        self.session = URLSession.shared

        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    // MARK: - Public Methods

    func get<T: Decodable>(endpoint: String) async throws -> T {
        return try await request(method: "GET", endpoint: endpoint)
    }

    func post<T: Decodable, B: Encodable>(endpoint: String, body: B) async throws -> T {
        return try await request(method: "POST", endpoint: endpoint, body: body)
    }

    func post<T: Decodable>(endpoint: String) async throws -> T {
        return try await request(method: "POST", endpoint: endpoint)
    }

    func patch<T: Decodable, B: Encodable>(endpoint: String, body: B) async throws -> T {
        return try await request(method: "PATCH", endpoint: endpoint, body: body)
    }

    func delete<T: Decodable>(endpoint: String) async throws -> T {
        return try await request(method: "DELETE", endpoint: endpoint)
    }

    func delete(endpoint: String) async throws {
        let _: EmptyResponse = try await request(method: "DELETE", endpoint: endpoint)
    }

    // MARK: - Private

    private func request<T: Decodable>(
        method: String,
        endpoint: String,
        body: (any Encodable)? = nil,
        retryOnUnauthorized: Bool = true
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = AuthService.shared.jwt {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            do {
                urlRequest.httpBody = try encoder.encode(body)
            } catch {
                throw APIError.encodingError(error)
            }
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw APIError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 401 && retryOnUnauthorized {
            await AuthService.shared.signOut()
            throw APIError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

private struct EmptyResponse: Decodable {}
