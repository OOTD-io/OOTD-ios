//
//  AuthenticationState.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/10/25.
//


//
// AuthenticationViewModel.swift
// Favourites
//
// Created by Peter Friese on 08.07.2022
// Copyright © 2022 Google LLC.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

// For Sign in with Apple
import AuthenticationServices
import CryptoKit
import Supabase
//import .supabase

enum AuthenticationState {
  case unauthenticated
  case authenticating
  case authenticated
}

enum AuthenticationFlow {
  case login
  case signUp
}

@MainActor
class AuthenticationViewModel: ObservableObject {
  @Published var email = ""
  @Published var password = ""
  @Published var confirmPassword = ""

  @Published var flow: AuthenticationFlow = .login

  @Published var isValid = false
  @Published var authenticationState: AuthenticationState = .unauthenticated
  @Published var errorMessage = ""
  @Published var user: User?
  @Published var displayName = ""

  private var currentNonce: String?

  init() {
    registerAuthStateHandler()
    verifySignInWithAppleAuthenticationState()

    $flow
      .combineLatest($email, $password, $confirmPassword)
      .map { flow, email, password, confirmPassword in
        flow == .login
        ? !(email.isEmpty || password.isEmpty)
        : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
      }
      .assign(to: &$isValid)
  }

//  private var authStateHandler: AuthStateDidChangeListenerHandle?

  func registerAuthStateHandler() {
      
//    if authStateHandler == nil {
//        try await supabase.auth.session { session in
//            self.user = session.user
//            self.authenticationState = session.user == nil ? .unauthenticated : .authenticated
//            self.displayName = session.user?.displayName ?? user?.email ?? ""
//      }
//    }
  }

  func switchFlow() {
    flow = flow == .login ? .signUp : .login
    errorMessage = ""
  }

  private func wait() async {
    do {
      print("Wait")
      try await Task.sleep(nanoseconds: 1_000_000_000)
      print("Done")
    }
    catch {
      print(error.localizedDescription)
    }
  }

  func reset() {
    flow = .login
    email = ""
    password = ""
    confirmPassword = ""
  }
}

// MARK: - Email and Password Authentication

extension AuthenticationViewModel {
  func signInWithEmailPassword() async -> Bool {
//      return true
    authenticationState = .authenticating
    do {
      try await supabase.auth.signIn(email: self.email, password: self.password)
        user = try await supabase.auth.user()
        authenticationState = .authenticated
      return true
    }
    catch  {
      print(error)
      errorMessage = error.localizedDescription
      authenticationState = .unauthenticated
      return false
    }
  }

  func signUpWithEmailPassword() async -> Bool {
      authenticationState = .authenticating
    Task {
          do {
              let response = try await supabase.auth.signUp(email: email, password: password)
              if let session = response.session {
                  authenticationState = .authenticated
                  user = response.user
                  print("Signup successful. Session: \(session)")
                  return user != nil
              } else {
                  print("Signup succeeded but no session returned.")
              }
              return true
          } catch {
              print("Signup failed: \(error.localizedDescription)")
              return false
          }
    }

      return user != nil
  }

    func signOut() async -> Bool {
        authenticationState = .unauthenticated
        do {
            try await supabase.auth.signOut()
            authenticationState = .unauthenticated
          return true
        }
        catch  {
          print(error)
          errorMessage = error.localizedDescription
          authenticationState = .unauthenticated
          return false
        }
  }

  func deleteAccount() async -> Bool {
      return true
//    do {
//      try await user?.delete()
//      return true
//    }
//    catch {
//      errorMessage = error.localizedDescription
//      return false
//    }
  }

  func sendPasswordReset(for email: String) async {
    do {
        print("Sending password reset for \(email)")
        try await supabase.auth.resetPassword(
            for: email,
            redirectTo: URL(string: "com.ootd.dev://reset-password")!
        )
    } catch {
        print("Error sending password reset: \(error.localizedDescription)")
        errorMessage = error.localizedDescription
    }
  }
}

// MARK: Sign in with Apple

extension AuthenticationViewModel {

  func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
    request.requestedScopes = [.fullName, .email]
    let nonce = randomNonceString()
    currentNonce = nonce
    request.nonce = sha256(nonce)
  }

  func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
//    if case .failure(let failure) = result {
//      errorMessage = failure.localizedDescription
//    }
//    else if case .success(let authorization) = result {
//      if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//        guard let nonce = currentNonce else {
//          fatalError("Invalid state: a login callback was received, but no login request was sent.")
//        }
//        guard let appleIDToken = appleIDCredential.identityToken else {
//          print("Unable to fetdch identify token.")
//          return
//        }
//        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//          print("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
//          return
//        }
//
//        let credential = OAuthProvider.credential(withProviderID: "apple.com",
//                                                  idToken: idTokenString,
//                                                  rawNonce: nonce)
//        Task {
//          do {
//            let result = try await Auth.auth().signIn(with: credential)
//            await updateDisplayName(for: result.user, with: appleIDCredential)
//          }
//          catch {
//            print("Error authenticating: \(error.localizedDescription)")
//          }
//        }
//      }
//    }
  }

  func updateDisplayName(for user: User, with appleIDCredential: ASAuthorizationAppleIDCredential, force: Bool = false) async {
//    if let currentDisplayName = Auth.auth().currentUser?.displayName, !currentDisplayName.isEmpty {
//      // current user is non-empty, don't overwrite it
//    }
//    else {
//      let changeRequest = user.createProfileChangeRequest()
//      changeRequest.displayName = appleIDCredential.displayName()
//      do {
//        try await changeRequest.commitChanges()
//        self.displayName = Auth.auth().currentUser?.displayName ?? ""
//      }
//      catch {
//        print("Unable to update the user's displayname: \(error.localizedDescription)")
//        errorMessage = error.localizedDescription
//      }
//    }
  }

  func verifySignInWithAppleAuthenticationState() {
//    let appleIDProvider = ASAuthorizationAppleIDProvider()
//    let providerData = Auth.auth().currentUser?.providerData
//    if let appleProviderData = providerData?.first(where: { $0.providerID == "apple.com" }) {
//      Task {
//        do {
//          let credentialState = try await appleIDProvider.credentialState(forUserID: appleProviderData.uid)
//          switch credentialState {
//          case .authorized:
//            break // The Apple ID credential is valid.
//          case .revoked, .notFound:
//            // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
//            self.signOut()
//          default:
//            break
//          }
//        }
//        catch {
//        }
//      }
//    }
  }

}

extension ASAuthorizationAppleIDCredential {
  func displayName() -> String {
    return [self.fullName?.givenName, self.fullName?.familyName]
      .compactMap( {$0})
      .joined(separator: " ")
  }
}

// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
private func randomNonceString(length: Int = 32) -> String {
  precondition(length > 0)
  let charset: [Character] =
  Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
  var result = ""
  var remainingLength = length

  while remainingLength > 0 {
    let randoms: [UInt8] = (0 ..< 16).map { _ in
      var random: UInt8 = 0
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }
      return random
    }

    randoms.forEach { random in
      if remainingLength == 0 {
        return
      }

      if random < charset.count {
        result.append(charset[Int(random)])
        remainingLength -= 1
      }
    }
  }

  return result
}

private func sha256(_ input: String) -> String {
  let inputData = Data(input.utf8)
  let hashedData = SHA256.hash(data: inputData)
  let hashString = hashedData.compactMap {
    String(format: "%02x", $0)
  }.joined()

  return hashString
}
