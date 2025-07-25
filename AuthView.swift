//
//  AuthView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/10/25.
//


import SwiftUI
import AuthenticationServices


struct AuthView: View {
    @State private var isLoginMode = true

    // Common
    @State private var email = ""
    @State private var password = ""

    // Registration only
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var confirmPassword = ""

    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            // Replace this image with your logo
            Image(systemName: "app.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.top, 30)

            // Toggle buttons
            HStack(spacing: 0) {
                Button(action: { isLoginMode = true }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isLoginMode ? Color.blue.opacity(0.2) : Color.clear)
                        .foregroundColor(isLoginMode ? .blue : .gray)
                }

                Button(action: { isLoginMode = false }) {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!isLoginMode ? Color.blue.opacity(0.2) : Color.clear)
                        .foregroundColor(!isLoginMode ? .blue : .gray)
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            ScrollView {
                VStack(spacing: 15) {
                    if !isLoginMode {
                        HStack {
                            TextField("First Name", text: $firstName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Last Name", text: $lastName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }

                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    if !isLoginMode {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    Button(action: {
                        if isLoginMode {
                            authVM.login(email: email, password: password)
                        } else {
                            guard password == confirmPassword else {
                                authVM.errorMessage = "Passwords do not match"
                                return
                            }
                            authVM.signup(email: email, password: password)
                            // Optionally send firstName and lastName to Firestore here
                        }
                    }) {
                        Text(isLoginMode ? "Login" : "Register")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    // Apple Sign-In
                    SignInWithAppleButton(.signIn,
                                          onRequest: authVM.signInWithAppleRequest,
                                          onCompletion: authVM.handleAppleSignIn)
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .cornerRadius(10)

                    if let error = authVM.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top)
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
    }
}


struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
