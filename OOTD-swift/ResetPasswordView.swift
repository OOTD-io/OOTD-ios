import SwiftUI

struct ResetPasswordView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Reset Your Password")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Please enter your new password below.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            SecureField("New Password", text: $newPassword)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            SecureField("Confirm New Password", text: $confirmNewPassword)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            if viewModel.isUpdatingPassword {
                ProgressView()
            } else {
                Button(action: {
                    Task {
                        // The token is not needed here because the user's session
                        // was already updated by the deep link handler.
                        await viewModel.updateUserPassword(newPassword: newPassword)
                    }
                }) {
                    Text("Update Password")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(newPassword.isEmpty || newPassword != confirmNewPassword)
            }

            if let errorMessage = viewModel.passwordUpdateErrorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Spacer()
        }
        .padding()
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
            .environmentObject(AuthenticationViewModel())
    }
}
