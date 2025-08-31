import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Forgot Password")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Enter the email address associated with your account and we'll send you a link to reset your password.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                if viewModel.isSendingPasswordReset {
                    ProgressView()
                } else {
                    Button(action: {
                        Task {
                            await viewModel.sendPasswordResetEmail()
                        }
                    }) {
                        Text("Send Reset Link")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                if let errorMessage = viewModel.passwordResetErrorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                if viewModel.passwordResetEmailSent {
                    Text("If an account exists for this email, a password reset link has been sent.")
                        .foregroundColor(.green)
                        .font(.caption)
                }

                Spacer()
            }
            .padding()
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
            .environmentObject(AuthenticationViewModel())
    }
}
