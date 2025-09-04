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

                    // Immediately check if this is a recovery URL and set the state.
                    // This avoids the race condition on app startup.
                    let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                    if let fragment = components?.fragment, fragment.contains("type=recovery") {
                        appRouter.showResetPasswordView = true
                    }

                    // Process the Supabase session in the background.
                    // This will ensure the user is authenticated when they try to update their password.
                    Task {
                        do {
                            try await supabase.auth.session(from: url)
                        } catch {
                            print("Error processing Supabase session from URL: \(error.localizedDescription)")
                        }
                    }
                }
        }
    }
}
