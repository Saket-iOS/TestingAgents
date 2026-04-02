import Foundation
import Observation

@Observable
final class CreateAccountViewModel {
    var email = ""
    var password = ""
    var isPasswordVisible = false
    var emailError: String?
    var passwordError: String?
    var errorMessage: String?
    private(set) var isLoading = false
    private(set) var isAccountCreated = false

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    var passwordStrength: PasswordStrength? {
        PasswordStrength.evaluate(password)
    }

    var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    func createAccount() async {
        emailError = nil
        passwordError = nil
        errorMessage = nil

        guard validateEmail() else { return }
        guard validatePassword() else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await authService.register(email: email, password: password)
            isAccountCreated = true
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

    private func validatePassword() -> Bool {
        guard password.count >= 8 else {
            passwordError = String(localized: "Password does not meet requirements.")
            return false
        }
        let hasUppercase = password.contains(where: \.isUppercase)
        let hasNumber = password.contains(where: \.isNumber)
        let hasSpecial = password.contains(where: { "!@#$%^&*()_+-=[]{}|;':\",./<>?".contains($0) })

        guard hasUppercase && hasNumber && hasSpecial else {
            passwordError = String(localized: "Password does not meet requirements.")
            return false
        }
        return true
    }
}
