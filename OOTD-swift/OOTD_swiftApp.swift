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
    @StateObject private var authViewModel = AuthenticationViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .preferredColorScheme(.light)
                .onOpenURL { url in
                    Task {
                        do {
                            try await supabase.auth.session(from: url)
                            // The user is now logged in and the session is updated.
                            // We can now navigate to a screen to reset the password.
                            // For now, we'll just print a confirmation.
                            print("Successfully handled deep link and updated session.")
                            authViewModel.isShowingResetPassword = true
                        } catch {
                            print("Failed to handle deep link: \(error.localizedDescription)")
                        }
                    }
                }
        }
    }
}
