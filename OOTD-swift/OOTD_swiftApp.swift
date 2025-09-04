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
                // Introduce a small delay to allow the app's view hierarchy to settle
                // before we try to programmatically navigate. This helps avoid race conditions on launch.
                Task {
                    // Wait for 0.1 seconds
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    await MainActor.run {
                        appRouter.showResetPasswordView = true
                    }
                }
            }
        }
    }
}
