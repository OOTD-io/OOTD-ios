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
                    Task {
                        do {
                            // 1. Let Supabase process the URL
                            try await supabase.auth.session(from: url)

                            // 2. Check if it's a password recovery URL
                            // Supabase password recovery URLs typically look like:
                            // your-app://your-host#access_token=...&refresh_token=...&type=recovery
                            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                            if let fragment = components?.fragment, fragment.contains("type=recovery") {
                                // It's a recovery link, so trigger the UI change
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
