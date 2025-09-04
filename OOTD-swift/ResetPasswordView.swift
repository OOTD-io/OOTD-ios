//
//  ResetPasswordView.swift
//  OOTD-swift
//
//  Created by Jules on 9/3/25.
//

import SwiftUI

struct ResetPasswordView: View {
    @StateObject private var viewModel = ResetPasswordViewModel()
    @EnvironmentObject private var appRouter: AppRouter

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isPasswordUpdated {
                // Success State
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                Text("Password Updated!")
                    .font(.title)
                    .bold()
                Text("You can now log in with your new password.")
                    .multilineTextAlignment(.center)
                    .padding()

                Button(action: {
                    appRouter.showResetPasswordView = false
                }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            } else {
                // Form State
                Text("Reset Your Password")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Enter and confirm your new password below.")
                    .foregroundColor(.secondary)

                SecureField("New Password", text: $viewModel.password)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                SecureField("Confirm New Password", text: $viewModel.confirmPassword)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button(action: {
                    Task { await viewModel.updatePassword() }
                }) {
                    Text("Update Password")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isValid ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!viewModel.isValid)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Reset Password")
    }
}

#Preview {
    ResetPasswordView()
}
