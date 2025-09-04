//
//  AppDelegate.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 5/27/25.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        let user = supabase.auth.currentUser

        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        // Ensure we are only handling our app's specific auth URLs
        guard url.scheme == "ootd" && url.host == "auth-callback" else {
            return false
        }

        // Post a notification if it's a password recovery link
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if let fragment = components?.fragment, fragment.contains("type=recovery") {
            NotificationCenter.default.post(name: .didReceivePasswordRecoveryURL, object: nil)
        }

        // Always try to process the session from the URL
        Task {
            do {
                _ = try await supabase.auth.session(from: url)
            } catch {
                print("Error processing Supabase session from URL in AppDelegate: \(error.localizedDescription)")
            }
        }

        return true
    }
}
