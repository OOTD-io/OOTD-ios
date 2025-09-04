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
            ContentView()
                .preferredColorScheme(.light)
                .environmentObject(appRouter)
                .onOpenURL { url in
                    // Ensure we are only handling our app's specific auth URLs
                    guard url.scheme == "ootd" && url.host == "auth-callback" else {
                        return
                    }

                    Task {
                        do {
                            // 1. Let Supabase process the URL to handle the session
                            try await supabase.auth.session(from: url)

                            // 2. Check if it's a password recovery URL to trigger the UI
                            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                            if let fragment = components?.fragment, fragment.contains("type=recovery") {
                                appRouter.showResetPasswordView = true
                            }
                        } catch {
                            print("Error handling URL: \(error.localizedDescription)")
                        }
                    }
                }
        }
    }
}
