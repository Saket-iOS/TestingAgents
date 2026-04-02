import Foundation

@MainActor
final class ServiceContainer {
    static let shared = ServiceContainer()

    lazy var authService: AuthServiceProtocol = AuthService()

    private init() {}
}
