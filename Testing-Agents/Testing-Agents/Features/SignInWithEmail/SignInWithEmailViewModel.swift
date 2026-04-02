import Foundation
import Observation

@MainActor
@Observable
final class SignInWithEmailViewModel {
    var email = ""
    var password = ""
    var isPasswordVisible = false
    var emailError: String?
    var passwordError: String?
    var errorMessage: String?
    private(set) var isLoading = false
    private(set) var isSignedIn = false
    private(set) var isLockedOut = false

    private let authService: AuthServiceProtocol
    private var lockoutTask: Task<Void, Never>?

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    func signIn() async {
        emailError = nil
        passwordError = nil
        errorMessage = nil

        guard validateEmail() else { return }
        guard validatePassword() else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await authService.login(email: email, password: password)
            isSignedIn = true
        } catch let error as APIError {
            handleAPIError(error)
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
        guard !password.isEmpty else {
            passwordError = String(localized: "Please enter your password.")
            return false
        }
        return true
    }

    private func handleAPIError(_ error: APIError) {
        switch error {
        case .rateLimited:
            errorMessage = error.errorDescription
            startLockout()
        default:
            errorMessage = error.errorDescription
        }
    }

    private func startLockout() {
        isLockedOut = true
        lockoutTask?.cancel()
        lockoutTask = Task {
            try? await Task.sleep(for: .seconds(30))
            if !Task.isCancelled {
                isLockedOut = false
            }
        }
    }
}
