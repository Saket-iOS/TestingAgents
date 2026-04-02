import SwiftUI

struct CreateAccountView: View {
    @Bindable var viewModel: CreateAccountViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.sectionSpacing) {
                emailSection
                passwordSection
                createAccountButton
                signInLink
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.top, Constants.sectionSpacing)
        }
        .background(Constants.backgroundColor)
        .navigationTitle(String(localized: "Create your account"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: Constants.backIcon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Constants.primaryColor)
                }
                .accessibilityLabel(String(localized: "Back"))
            }
        }
        .alert(String(localized: "Error"), isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button(String(localized: "OK")) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var emailSection: some View {
        VStack(alignment: .leading, spacing: Constants.innerSpacing) {
            Text(String(localized: "Email"))
                .font(.system(size: Constants.bodyFontSize, weight: .bold))
                .foregroundStyle(Constants.primaryColor)

            TextField(String(localized: "Email address"), text: $viewModel.email)
                .font(.system(size: Constants.bodyFontSize))
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: Constants.inputCornerRadius))
                .accessibilityLabel(String(localized: "Email address"))

            if let emailError = viewModel.emailError {
                Text(emailError)
                    .font(.system(size: Constants.captionFontSize))
                    .foregroundStyle(.red)
            }
        }
    }

    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: Constants.innerSpacing) {
            Text(String(localized: "Password"))
                .font(.system(size: Constants.bodyFontSize, weight: .bold))
                .foregroundStyle(Constants.primaryColor)

            HStack {
                Group {
                    if viewModel.isPasswordVisible {
                        TextField(String(localized: "Password"), text: $viewModel.password)
                    } else {
                        SecureField(String(localized: "Password"), text: $viewModel.password)
                    }
                }
                .font(.system(size: Constants.bodyFontSize))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                Button {
                    viewModel.isPasswordVisible.toggle()
                } label: {
                    Image(systemName: viewModel.isPasswordVisible ? Constants.showPasswordIcon : Constants.hidePasswordIcon)
                        .foregroundStyle(.gray)
                        .frame(minWidth: Constants.toggleMinWidth)
                }
                .accessibilityLabel(String(localized: viewModel.isPasswordVisible ? "Hide password" : "Show password"))
            }
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: Constants.inputCornerRadius))

            HStack {
                Spacer()
                if let strength = viewModel.passwordStrength {
                    Text(strength.label)
                        .font(.system(size: Constants.captionFontSize, weight: .medium))
                        .foregroundStyle(strength.color)
                }
            }

            if let passwordError = viewModel.passwordError {
                Text(passwordError)
                    .font(.system(size: Constants.captionFontSize))
                    .foregroundStyle(.red)
            }
        }
    }

    private var createAccountButton: some View {
        Button {
            Task {
                await viewModel.createAccount()
            }
        } label: {
            ZStack {
                Text(String(localized: "Create Account"))
                    .font(.system(size: Constants.bodyFontSize, weight: .bold))
                    .foregroundStyle(.white)
                    .opacity(viewModel.isLoading ? 0 : 1)

                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Constants.buttonHeight)
            .background(Constants.primaryColor)
            .clipShape(RoundedRectangle(cornerRadius: Constants.buttonCornerRadius))
        }
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
        .opacity(viewModel.isFormValid ? 1.0 : Constants.disabledOpacity)
        .accessibilityLabel(String(localized: "Create Account"))
        .padding(.top, Constants.innerSpacing)
    }

    private var signInLink: some View {
        HStack(spacing: Constants.linkSpacing) {
            Text(String(localized: "Already have an account?"))
                .font(.system(size: Constants.linkFontSize))
                .foregroundStyle(.secondary)

            NavigationLink(String(localized: "Sign In"), value: AuthRoute.signIn)
                .font(.system(size: Constants.linkFontSize, weight: .bold))
                .foregroundStyle(Constants.primaryColor)
                .accessibilityLabel(String(localized: "Sign In"))
        }
    }
}

// MARK: - Constants

private enum Constants {
    static let backgroundColor = Color(red: 237.0 / 255.0, green: 238.0 / 255.0, blue: 243.0 / 255.0)
    static let primaryColor = Color(red: 27.0 / 255.0, green: 42.0 / 255.0, blue: 74.0 / 255.0)

    static let bodyFontSize: CGFloat = 16
    static let captionFontSize: CGFloat = 13
    static let linkFontSize: CGFloat = 14

    static let sectionSpacing: CGFloat = 24
    static let innerSpacing: CGFloat = 8
    static let horizontalPadding: CGFloat = 20
    static let linkSpacing: CGFloat = 4

    static let inputCornerRadius: CGFloat = 12
    static let buttonCornerRadius: CGFloat = 14
    static let buttonHeight: CGFloat = 50

    static let disabledOpacity: CGFloat = 0.5
    static let toggleMinWidth: CGFloat = 44

    static let backIcon = "chevron.left"
    static let showPasswordIcon = "eye"
    static let hidePasswordIcon = "eye.slash"
}

#Preview {
    NavigationStack {
        CreateAccountView(
            viewModel: CreateAccountViewModel(authService: MockAuthService())
        )
    }
}
