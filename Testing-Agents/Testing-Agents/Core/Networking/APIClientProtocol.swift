import Foundation

protocol APIClientProtocol {
    nonisolated func request<T: Decodable & Sendable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T
    nonisolated func requestVoid(_ endpoint: Endpoint) async throws
}
