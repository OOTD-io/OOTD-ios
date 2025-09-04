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
    @StateObject private var appRouter = AppRouter()

    var body: some Scene {
        WindowGroup {
            Group {
                if appRouter.showResetPasswordView {
                    // If a reset link was clicked, show the ResetPasswordView first.
                    NavigationView {
                        ResetPasswordView()
                            .environmentObject(appRouter) // Pass router for dismissal
                    }
                } else {
                    // Otherwise, show the normal content view.
                    ContentView()
                        .environmentObject(appRouter) // Pass router for other potential navigation
                }
            }
            .preferredColorScheme(.light)
            .onReceive(NotificationCenter.default.publisher(for: .didReceivePasswordRecoveryURL)) { _ in
                // When we receive the notification from the AppDelegate, trigger the navigation
                appRouter.showResetPasswordView = true
            }
        }
    }
}
