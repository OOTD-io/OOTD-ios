import Foundation
import AuthenticationServices
import CryptoKit
import Supabase

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
  // MARK: - Published Properties
  @Published var email = ""
  @Published var password = ""
  @Published var confirmPassword = ""

  @Published var flow: AuthenticationFlow = .login

  @Published var isValid = false
  @Published var authenticationState: AuthenticationState = .unauthenticated
  @Published var errorMessage = ""
  @Published var user: User?
  @Published var displayName = ""

  // For Forgot Password Flow
  @Published var isSendingPasswordReset = false
  @Published var passwordResetEmailSent = false
  @Published var passwordResetErrorMessage: String? = nil

  // For Reset Password Flow
  @Published var needsPasswordReset = false
  @Published var isUpdatingPassword = false
  @Published var passwordUpdateErrorMessage: String? = nil

  private var authStateHandler: Any?
  private var currentNonce: String?

  init() {
    // Kick off the async state handler registration from the synchronous initializer
    Task {
        await self.registerAuthStateHandler()
    }

    $flow
      .combineLatest($email, $password, $confirmPassword)
      .map { flow, email, password, confirmPassword in
        flow == .login
        ? !(email.isEmpty || password.isEmpty)
        : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
      }
      .assign(to: &$isValid)
  }

  // MARK: - Auth State
  func registerAuthStateHandler() async {
      if authStateHandler == nil {
          authStateHandler = await supabase.auth.onAuthStateChange { [weak self] (event, session) in
              guard let self = self else { return }

              Task { @MainActor in
                  if let user = session?.user {
                      self.user = user
                      self.authenticationState = .authenticated
                      self.displayName = user.email ?? ""
                  } else {
                      self.user = nil
                      self.authenticationState = .unauthenticated
                      self.displayName = ""
                  }

                  if event == .passwordRecovery {
                      self.needsPasswordReset = true
                  }
              }
          }
      }
  }

  func switchFlow() {
    flow = flow == .login ? .signUp : .login
    errorMessage = ""
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
    func sendPasswordResetEmail() async {
        isSendingPasswordReset = true
        passwordResetErrorMessage = nil
        passwordResetEmailSent = false

        do {
            try await supabase.auth.resetPasswordForEmail(email)
            passwordResetEmailSent = true
        }
        catch {
            passwordResetErrorMessage = error.localizedDescription
        }

        isSendingPasswordReset = false
    }

    func updateUserPassword(newPassword: String) async {
        isUpdatingPassword = true
        passwordUpdateErrorMessage = nil

        do {
            try await supabase.auth.update(user: UserAttributes(password: newPassword))
            needsPasswordReset = false
            await self.signOut()
        }
        catch {
            passwordUpdateErrorMessage = error.localizedDescription
        }

        isUpdatingPassword = false
    }

    func signInWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do {
            try await supabase.auth.signIn(email: self.email, password: self.password)
            return true
        }
        catch  {
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }

    func signUpWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do {
            try await supabase.auth.signUp(email: email, password: password)
            return true
        } catch {
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }

    func signOut() async -> Bool {
        do {
            try await supabase.auth.signOut()
            return true
        }
        catch  {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteAccount() async -> Bool {
        // This is a placeholder, actual implementation would be needed.
        return true
    }
}

// MARK: - Sign in with Apple
extension AuthenticationViewModel {

  func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
    request.requestedScopes = [.fullName, .email]
    let nonce = randomNonceString()
    currentNonce = nonce
    request.nonce = sha256(nonce)
  }

  func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
      if case .success(let authorization) = result {
          if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
              guard let nonce = currentNonce else {
                fatalError("Invalid state: a login callback was received, but no login request was sent.")
              }
              guard let appleIDToken = appleIDCredential.identityToken else {
                return
              }
              guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                return
              }

              Task {
                  do {
                      try await supabase.auth.signInWithIdToken(
                        credentials: .init(provider: .apple, idToken: idTokenString, nonce: nonce)
                      )
                  } catch {
                      self.errorMessage = error.localizedDescription
                  }
              }
          }
      }
  }
}

// MARK: - Helpers
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
        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
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
