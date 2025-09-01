import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Forgot Password")
                .font(.largeTitle.bold())

            Text("Enter your email address and we'll send you a link to reset your password.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            TextField("Email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)

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

            if viewModel.passwordResetEmailSent {
                Text("A password reset link has been sent to your email.")
                    .foregroundColor(.green)
            }

            if let errorMessage = viewModel.passwordResetErrorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Spacer()

            Button("Back to Login") {
                dismiss()
            }
        }
        .padding()
    }
}

#Preview {
    ForgotPasswordView()
        .environmentObject(AuthenticationViewModel())
}
