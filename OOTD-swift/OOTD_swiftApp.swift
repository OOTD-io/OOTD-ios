//
//  OOTD_swiftApp.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 5/26/25.
//

import SwiftUI

@main
struct OOTD_swiftApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // The AuthenticationViewModel now lives here as the source of truth for auth state.
    @StateObject private var authViewModel = AuthenticationViewModel()

    // State for handling the password reset flow, managed at the root of the app.
    @State private var recoveryURL: URL?
    @State private var showPasswordReset = false

    var body: some Scene {
        WindowGroup {
            // Group acts as a container for our main view logic.
            Group {
                // The view shown depends on the authentication state.
                if authViewModel.authenticationState == .authenticated {
                    HomeView {
                        // The `content` for HomeView in the authenticated state.
                        // This seems to be the original pattern, so we preserve it.
                        EmptyView()
                    }
                    .environmentObject(authViewModel)
                } else {
                    // If not authenticated, show the AuthenticationView wrapper.
                    // Note: The user's guide suggested LoginView(), but AuthenticationView
                    // contains the logic to switch between Login and Sign Up, so it's more complete.
                    AuthenticationView()
                        .environmentObject(authViewModel)
                }
            }
            .preferredColorScheme(.light)
            // The listener for the deep link notification lives here, at the highest
            // possible level, ensuring it catches the event on app launch.
            .onReceive(NotificationCenter.default.publisher(for: .didReceivePasswordRecoveryURL)) { notif in
                if let url = notif.object as? URL {
                    print("DEBUG: Root App received recovery notification: \(url)")
                    self.recoveryURL = url
                    self.showPasswordReset = true
                }
            }
            // The sheet for resetting the password is also presented from the root,
            // ensuring it can be shown regardless of the current navigation state.
            .sheet(isPresented: $showPasswordReset) {
                ResetPasswordView(url: recoveryURL)
            }
        }
    }
}
