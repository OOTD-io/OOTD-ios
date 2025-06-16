//
//  AuthViewModel.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/10/25.
//


import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    private var currentNonce: String?

    init() {
        self.isAuthenticated = Auth.auth().currentUser != nil
    }

    func login(email: String, password: String) {
        errorMessage = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            DispatchQueue.main.async {
                self?.isAuthenticated = error == nil
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func signup(email: String, password: String) {
        errorMessage = nil
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] _, error in
            DispatchQueue.main.async {
                self?.isAuthenticated = error == nil
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func signInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.email, .fullName]
        request.nonce = sha256(nonce)
    }

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            guard let credential = authResults.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let tokenString = String(data: tokenData, encoding: .utf8),
                  let nonce = currentNonce else {
                self.errorMessage = "Apple sign-in failed."
                return
            }

            let firebaseCredential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: tokenString,
                rawNonce: nonce
            )

            Auth.auth().signIn(with: firebaseCredential) { [weak self] _, error in
                DispatchQueue.main.async {
                    self?.isAuthenticated = error == nil
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }

        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        self.isAuthenticated = false
    }

    // MARK: - Apple Sign In Helpers
    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }

    private func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms = (0 ..< 16).map { _ in UInt8.random(in: 0...255) }
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random) % charset.count])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
}
