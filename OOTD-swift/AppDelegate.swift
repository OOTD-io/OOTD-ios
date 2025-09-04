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

        print("DEBUG: AppDelegate received URL: \(url.absoluteString)")

        // Ensure we are only handling our app's specific auth URLs
        guard url.scheme == "ootd" && url.host == "auth-callback" else {
            print("DEBUG: URL is not for this app. Ignoring.")
            return false
        }

        // Check if it's a password recovery link by looking at the fragment
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if let fragment = components?.fragment, fragment.contains("type=recovery") {
            print("DEBUG: URL is a password recovery link. Posting notification.")
            NotificationCenter.default.post(name: .didReceivePasswordRecoveryURL, object: nil)
        } else {
            print("DEBUG: URL is for auth callback, but not for password recovery.")
        }

        // Always try to process the session from the URL in a background task
        Task {
            do {
                _ = try await supabase.auth.session(from: url)
                print("DEBUG: Supabase session successfully processed from URL.")
            } catch {
                print("DEBUG: Error processing Supabase session from URL in AppDelegate: \(error.localizedDescription)")
            }
        }

        return true
    }
}
