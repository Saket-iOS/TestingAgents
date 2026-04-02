import SwiftUI

struct SignInWithEmailView: View {
    @Bindable var viewModel: SignInWithEmailViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case email
        case password
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.sectionSpacing) {
                emailSection
                passwordSection
                signInButton
                linksSection
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.top, Constants.sectionSpacing)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Constants.backgroundColor)
        .navigationTitle(String(localized: "Sign in with email"))
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

    // MARK: - Email Section

    private var emailSection: some View {
        VStack(alignment: .leading, spacing: Constants.innerSpacing) {
            Text(String(localized: "Email"))
                .font(.system(size: Constants.bodyFontSize, weight: .bold))
                .foregroundStyle(Constants.primaryColor)

            TextField(String(localized: "Email address"), text: $viewModel.email)
                .font(.system(size: Constants.bodyFontSize))
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .onSubmit { focusedField = .password }
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: Constants.inputCornerRadius))
                .accessibilityLabel(String(localized: "Email address"))

            if let emailError = viewModel.emailError {
                Text(emailError)
                    .font(.system(size: Constants.captionFontSize))
                    .foregroundStyle(.red)
                    .accessibilityLabel(emailError)
            }
        }
    }

    // MARK: - Password Section

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
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .password)
                .submitLabel(.go)
                .onSubmit {
                    if viewModel.isFormValid && !viewModel.isLoading && !viewModel.isLockedOut {
                        Task { await viewModel.signIn() }
                    }
                }

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

            if let passwordError = viewModel.passwordError {
                Text(passwordError)
                    .font(.system(size: Constants.captionFontSize))
                    .foregroundStyle(.red)
                    .accessibilityLabel(passwordError)
            }
        }
    }

    // MARK: - Sign In Button

    private var signInButton: some View {
        Button {
            Task { await viewModel.signIn() }
        } label: {
            ZStack {
                Text(String(localized: "Sign in"))
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
        .disabled(!viewModel.isFormValid || viewModel.isLoading || viewModel.isLockedOut)
        .opacity(viewModel.isFormValid && !viewModel.isLockedOut ? 1.0 : Constants.disabledOpacity)
        .accessibilityLabel(String(localized: "Sign in"))
        .padding(.top, Constants.innerSpacing)
    }

    // MARK: - Links Section

    private var linksSection: some View {
        VStack(spacing: Constants.linkSpacing) {
            NavigationLink(value: AuthRoute.forgotPassword) {
                Text(String(localized: "Forgot password?"))
            }
            .font(.system(size: Constants.linkFontSize, weight: .bold))
            .foregroundStyle(Constants.primaryColor)
            .accessibilityLabel(String(localized: "Forgot password?"))

            HStack(spacing: Constants.linkInnerSpacing) {
                Text(String(localized: "New user?"))
                    .font(.system(size: Constants.linkFontSize))
                    .foregroundStyle(.secondary)

                Button(String(localized: "Create an account")) {
                    dismiss()
                }
                .font(.system(size: Constants.linkFontSize, weight: .bold))
                .foregroundStyle(Constants.primaryColor)
                .accessibilityLabel(String(localized: "Create an account"))
            }
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
    static let linkSpacing: CGFloat = 20
    static let linkInnerSpacing: CGFloat = 4

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
        SignInWithEmailView(
            viewModel: SignInWithEmailViewModel(authService: MockAuthService())
        )
    }
}
