import SwiftUI

struct CreateAccountView: View {
    @Bindable var viewModel: CreateAccountViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                emailSection
                passwordSection
                createAccountButton
                signInLink
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .background(Color(red: 237.0 / 255.0, green: 238.0 / 255.0, blue: 243.0 / 255.0))
        .navigationTitle(String(localized: "Create your account"))
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

    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "Email"))
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(red: 27.0 / 255.0, green: 42.0 / 255.0, blue: 74.0 / 255.0))

            TextField(String(localized: "Email address"), text: $viewModel.email)
                .font(.system(size: 16))
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityLabel(String(localized: "Email address"))

            if let emailError = viewModel.emailError {
                Text(emailError)
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
            }
        }
    }

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
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

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

            HStack {
                Spacer()
                if let strength = viewModel.passwordStrength {
                    Text(strength.label)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(strength.color)
                }
            }

            if let passwordError = viewModel.passwordError {
                Text(passwordError)
                    .font(.system(size: 13))
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
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
        .opacity(viewModel.isFormValid ? 1.0 : 0.5)
        .accessibilityLabel(String(localized: "Create Account"))
        .padding(.top, 8)
    }

    private var signInLink: some View {
        HStack(spacing: 4) {
            Text(String(localized: "Already have an account?"))
                .font(.system(size: 14))
                .foregroundStyle(.secondary)

            NavigationLink(String(localized: "Sign In"), value: AuthRoute.signIn)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color(red: 27.0 / 255.0, green: 42.0 / 255.0, blue: 74.0 / 255.0))
                .accessibilityLabel(String(localized: "Sign In"))
        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView(
            viewModel: CreateAccountViewModel(authService: MockAuthService())
        )
    }
}
