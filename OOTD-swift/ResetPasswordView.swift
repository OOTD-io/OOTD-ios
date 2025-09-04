//
//  ResetPasswordView.swift
//  OOTD-swift
//
//  Created by Jules on 9/3/25.
//
//  Implementation based on user-provided guide.
//

import SwiftUI
import Supabase

struct ResetPasswordView: View {
    let url: URL? // Passed in, though not directly used in the logic.
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isPasswordUpdated = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            if isPasswordUpdated {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                Text("Password Updated!")
                    .font(.title)
                    .bold()
                Text("You may now close this screen.")
                    .padding()
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

            } else {
                Text("Reset Your Password")
                    .font(.title)
                    .fontWeight(.bold)

                SecureField("New Password", text: $newPassword)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                SecureField("Confirm New Password", text: $confirmPassword)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)

                if newPassword != confirmPassword && !confirmPassword.isEmpty {
                    Text("Passwords do not match.")
                        .foregroundColor(.red)
                        .font(.caption)
                }

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button("Update Password") {
                    Task {
                        do {
                            try await supabase.auth.update(user: UserAttributes(password: newPassword))
                            self.errorMessage = nil
                            self.isPasswordUpdated = true
                        } catch {
                            self.errorMessage = error.localizedDescription
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(newPassword.isEmpty || newPassword != confirmPassword)
            }
        }
        .padding()
    }
}
