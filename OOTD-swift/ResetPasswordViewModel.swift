//
//  ResetPasswordViewModel.swift
//  OOTD-swift
//
//  Created by Jules on 9/3/25.
//

import SwiftUI
import Supabase

@MainActor
class ResetPasswordViewModel: ObservableObject {
    @Published var password = ""
    @Published var confirmPassword = ""

    @Published var errorMessage: String?
    @Published var isPasswordUpdated = false

    var isValid: Bool {
        !password.isEmpty && password == confirmPassword
    }

    func updatePassword() async {
        guard isValid else {
            errorMessage = "Passwords cannot be empty and must match."
            return
        }

        errorMessage = nil

        do {
            try await supabase.auth.update(user: UserAttributes(password: password))
            isPasswordUpdated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
