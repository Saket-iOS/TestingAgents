import SwiftUI

struct ForgotPasswordView: View {
    @Bindable var viewModel: ForgotPasswordViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(String(localized: "Enter your email address and we'll send you a link to reset your password."))
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                emailSection
                submitButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(red: 237.0 / 255.0, green: 238.0 / 255.0, blue: 243.0 / 255.0))
        .navigationTitle(String(localized: "Forgot password"))
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
        .onChange(of: viewModel.isSubmitted) { _, submitted in
            if submitted {
                dismiss()
            }
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
                .submitLabel(.go)
                .onSubmit {
                    if viewModel.isEmailValid && !viewModel.isLoading {
                        Task { await viewModel.submit() }
                    }
                }
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

    // MARK: - Submit Button

    private var submitButton: some View {
        Button {
            Task { await viewModel.submit() }
        } label: {
            ZStack {
                Text(String(localized: "Submit"))
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
        .disabled(!viewModel.isEmailValid || viewModel.isLoading)
        .opacity(viewModel.isEmailValid ? 1.0 : 0.5)
        .accessibilityLabel(String(localized: "Submit"))
        .padding(.top, 8)
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView(
            viewModel: ForgotPasswordViewModel(authService: MockAuthService())
        )
    }
}
