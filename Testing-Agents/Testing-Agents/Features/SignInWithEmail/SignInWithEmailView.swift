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
            VStack(spacing: 24) {
                emailSection
                passwordSection
                signInButton
                linksSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(red: 237.0 / 255.0, green: 238.0 / 255.0, blue: 243.0 / 255.0))
        .navigationTitle(String(localized: "Sign in with email"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color(red: 27.0 / 255.0, green: 42.0 / 255.0, blue: 74.0 / 255.0))
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
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "Email"))
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(red: 27.0 / 255.0, green: 42.0 / 255.0, blue: 74.0 / 255.0))

            TextField(String(localized: "Email address"), text: $viewModel.email)
                .font(.system(size: 16))
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .onSubmit { focusedField = .password }
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityLabel(String(localized: "Email address"))

            if let emailError = viewModel.emailError {
                Text(emailError)
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
                    .accessibilityLabel(emailError)
            }
        }
    }

    // MARK: - Password Section

    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "Password"))
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(red: 27.0 / 255.0, green: 42.0 / 255.0, blue: 74.0 / 255.0))

            HStack {
                Group {
                    if viewModel.isPasswordVisible {
                        TextField(String(localized: "Password"), text: $viewModel.password)
                    } else {
                        SecureField(String(localized: "Password"), text: $viewModel.password)
                    }
                }
                .font(.system(size: 16))
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
                    Image(systemName: viewModel.isPasswordVisible ? "eye" : "eye.slash")
                        .foregroundStyle(.gray)
                        .frame(minWidth: 44)
                }
                .accessibilityLabel(String(localized: viewModel.isPasswordVisible ? "Hide password" : "Show password"))
            }
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if let passwordError = viewModel.passwordError {
                Text(passwordError)
                    .font(.system(size: 13))
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
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .opacity(viewModel.isLoading ? 0 : 1)

                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(red: 27.0 / 255.0, green: 42.0 / 255.0, blue: 74.0 / 255.0))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!viewModel.isFormValid || viewModel.isLoading || viewModel.isLockedOut)
        .opacity(viewModel.isFormValid && !viewModel.isLockedOut ? 1.0 : 0.5)
        .accessibilityLabel(String(localized: "Sign in"))
        .padding(.top, 8)
    }

    // MARK: - Links Section

    private var linksSection: some View {
        VStack(spacing: 20) {
            NavigationLink(value: AuthRoute.forgotPassword) {
                Text(String(localized: "Forgot password?"))
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(Color(red: 27.0 / 255.0, green: 42.0 / 255.0, blue: 74.0 / 255.0))
            .accessibilityLabel(String(localized: "Forgot password?"))

            HStack(spacing: 4) {
                Text(String(localized: "New user?"))
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

                Button(String(localized: "Create an account")) {
                    dismiss()
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color(red: 27.0 / 255.0, green: 42.0 / 255.0, blue: 74.0 / 255.0))
                .accessibilityLabel(String(localized: "Create an account"))
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignInWithEmailView(
            viewModel: SignInWithEmailViewModel(authService: MockAuthService())
        )
    }
}
