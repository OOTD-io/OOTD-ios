//
//  AppDelegate.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 5/27/25.
//

import SwiftUI

extension Notification.Name {
    static let didReceivePasswordRecoveryURL = Notification.Name("didReceivePasswordRecoveryURL")
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        let user = supabase.auth.currentUser

        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        print("DEBUG: AppDelegate received URL: \(url.absoluteString)")

        guard url.scheme == "ootd" && url.host == "auth-callback" else {
            print("DEBUG: URL is not for this app. Ignoring.")
            return false
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)

        // Robustly check for recovery type in EITHER query params OR the fragment.
        let isRecoveryInQuery = components?.queryItems?.contains(where: { $0.name == "type" && $0.value == "recovery" }) ?? false
        let isRecoveryInFragment = components?.fragment?.contains("type=recovery") ?? false

        if isRecoveryInQuery || isRecoveryInFragment {
            print("DEBUG: Detected password recovery link. Posting notification and stopping.")
            NotificationCenter.default.post(name: .didReceivePasswordRecoveryURL, object: url)
            // For recovery, we only signal the app to show the reset view.
            // We do NOT process the session here, as that could interfere with the flow.
            return true
        }

        // For other links (e.g., magic link sign-in), process the session.
        print("DEBUG: Regular auth callback. Processing session.")
        Task {
            do {
                _ = try await supabase.auth.session(from: url)
                print("DEBUG: Supabase session processed from URL.")
            } catch {
                print("DEBUG: Error processing Supabase session: \(error.localizedDescription)")
            }
        }

        return true
    }
}
