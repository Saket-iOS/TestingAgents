import Foundation

struct AuthResponse: Sendable {
    let token: String
    let userId: String

    nonisolated init(token: String, userId: String) {
        self.token = token
        self.userId = userId
    }
}

extension AuthResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case token, userId
    }

    nonisolated init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.token = try container.decode(String.self, forKey: .token)
        self.userId = try container.decode(String.self, forKey: .userId)
    }
}

protocol AuthServiceProtocol {
    func register(email: String, password: String) async throws -> AuthResponse
    func login(email: String, password: String) async throws -> AuthResponse
}
