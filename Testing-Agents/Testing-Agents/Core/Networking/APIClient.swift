import Foundation

final class APIClient: APIClientProtocol, Sendable {
    static let shared = APIClient()

    private nonisolated let session: URLSession
    private nonisolated let decoder: JSONDecoder

    nonisolated init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    nonisolated func request<T: Decodable & Sendable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        let request = try endpoint.urlRequest()
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            throw Self.mapHTTPError(http.statusCode)
        }
        return try decoder.decode(T.self, from: data)
    }

    nonisolated func requestVoid(_ endpoint: Endpoint) async throws {
        let request = try endpoint.urlRequest()
        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            throw Self.mapHTTPError(http.statusCode)
        }
    }

    private nonisolated static func mapHTTPError(_ statusCode: Int) -> APIError {
        switch statusCode {
        case 401: return .incorrectCredentials
        case 404: return .accountNotFound
        case 409: return .emailAlreadyRegistered
        case 429: return .rateLimited
        default: return .http(statusCode)
        }
    }
}
