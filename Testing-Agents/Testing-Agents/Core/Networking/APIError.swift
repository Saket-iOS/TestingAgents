import Foundation

enum APIError: LocalizedError, Sendable {
    case invalidURL
    case invalidResponse
    case http(Int)
    case emailAlreadyRegistered
    case incorrectCredentials
    case accountNotFound
    case rateLimited
    case networkError(any Error)
    case unknown

    nonisolated var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: "Invalid URL")
        case .invalidResponse:
            return String(localized: "Invalid server response")
        case .http(let code):
            return String(localized: "Server error (code: \(code))")
        case .emailAlreadyRegistered:
            return String(localized: "This email is already registered. Please sign in instead.")
        case .incorrectCredentials:
            return String(localized: "Incorrect email or password.")
        case .accountNotFound:
            return String(localized: "No account found with this email address.")
        case .rateLimited:
            return String(localized: "Too many attempts. Please try again in 30 seconds.")
        case .networkError:
            return String(localized: "Network error. Please check your connection and try again.")
        case .unknown:
            return String(localized: "An unexpected error occurred")
        }
    }
}
