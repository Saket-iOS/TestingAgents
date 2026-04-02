import Foundation

final class MockAuthService: AuthServiceProtocol {
    func register(email: String, password: String) async throws -> AuthResponse {
        try await Task.sleep(for: .seconds(1))
        return AuthResponse(token: "mock-token", userId: "mock-user-id")
    }
}
