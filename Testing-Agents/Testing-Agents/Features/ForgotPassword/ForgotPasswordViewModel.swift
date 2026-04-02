import Foundation
import Observation

@MainActor
@Observable
final class ForgotPasswordViewModel {
    var email = ""
    var emailError: String?
    var errorMessage: String?
    private(set) var isLoading = false
    private(set) var isSubmitted = false

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    var isEmailValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        let emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        return trimmed.wholeMatch(of: emailRegex) != nil
    }

    func submit() async {
        emailError = nil
        errorMessage = nil

        guard validateEmail() else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.forgotPassword(email: email.trimmingCharacters(in: .whitespaces))
            isSubmitted = true
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = String(localized: "Network error. Please check your connection and try again.")
        }
    }

    private func validateEmail() -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            emailError = String(localized: "Please enter a valid email address.")
            return false
        }
        let emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        guard trimmed.wholeMatch(of: emailRegex) != nil else {
            emailError = String(localized: "Please enter a valid email address.")
            return false
        }
        return true
    }
}
