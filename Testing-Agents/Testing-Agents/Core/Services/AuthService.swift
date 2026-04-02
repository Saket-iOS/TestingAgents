import Foundation

final class AuthService: AuthServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    func register(email: String, password: String) async throws -> AuthResponse {
        let endpoint = Endpoint.register(email: email, password: password)
        return try await apiClient.request(endpoint, as: AuthResponse.self)
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let endpoint = Endpoint.login(email: email, password: password)
        return try await apiClient.request(endpoint, as: AuthResponse.self)
    }
}
