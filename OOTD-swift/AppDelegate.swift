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

        // Make sure it matches ootd://auth-callback
        guard url.scheme == "ootd", url.host == "auth-callback" else {
            print("DEBUG: URL is not for this app. Ignoring.")
            return false
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)

        // Check for password recovery flow via query params
        if let queryItems = components?.queryItems,
           queryItems.contains(where: { $0.name == "type" && $0.value == "recovery" }) {
            print("DEBUG: Detected password recovery link.")
            // Post the notification to trigger the UI
            NotificationCenter.default.post(name: .didReceivePasswordRecoveryURL, object: url)
        } else {
            print("DEBUG: Regular auth callback (sign-in or magic link).")
        }

        // Process session regardless, as it might be a magic link sign-in
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
