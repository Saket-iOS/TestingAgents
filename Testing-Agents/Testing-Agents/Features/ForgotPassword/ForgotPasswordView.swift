import SwiftUI

struct ForgotPasswordView: View {
    @Bindable var viewModel: ForgotPasswordViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.sectionSpacing) {
                Text(String(localized: "Enter your email address and we'll send you a link to reset your password."))
                    .font(.system(size: Constants.descriptionFontSize))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                emailSection
                submitButton
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.top, Constants.sectionSpacing)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Constants.backgroundColor)
        .navigationTitle(String(localized: "Forgot password"))
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
        .onChange(of: viewModel.isSubmitted) { _, submitted in
            if submitted {
                dismiss()
            }
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
                .submitLabel(.go)
                .onSubmit {
                    if viewModel.isEmailValid && !viewModel.isLoading {
                        Task { await viewModel.submit() }
                    }
                }
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

    // MARK: - Submit Button

    private var submitButton: some View {
        Button {
            Task { await viewModel.submit() }
        } label: {
            ZStack {
                Text(String(localized: "Submit"))
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
        .disabled(!viewModel.isEmailValid || viewModel.isLoading)
        .opacity(viewModel.isEmailValid ? 1.0 : Constants.disabledOpacity)
        .accessibilityLabel(String(localized: "Submit"))
        .padding(.top, Constants.innerSpacing)
    }
}

// MARK: - Constants

private enum Constants {
    static let backgroundColor = Color(red: 237.0 / 255.0, green: 238.0 / 255.0, blue: 243.0 / 255.0)
    static let primaryColor = Color(red: 27.0 / 255.0, green: 42.0 / 255.0, blue: 74.0 / 255.0)

    static let descriptionFontSize: CGFloat = 15
    static let bodyFontSize: CGFloat = 16
    static let captionFontSize: CGFloat = 13

    static let sectionSpacing: CGFloat = 24
    static let innerSpacing: CGFloat = 8
    static let horizontalPadding: CGFloat = 20

    static let inputCornerRadius: CGFloat = 12
    static let buttonCornerRadius: CGFloat = 14
    static let buttonHeight: CGFloat = 50

    static let disabledOpacity: CGFloat = 0.5

    static let backIcon = "chevron.left"
}

#Preview {
    NavigationStack {
        ForgotPasswordView(
            viewModel: ForgotPasswordViewModel(authService: MockAuthService())
        )
    }
}
