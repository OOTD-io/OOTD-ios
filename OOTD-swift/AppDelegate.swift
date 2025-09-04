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

        // Use the official Supabase helper function to identify a sign-in link.
        // This is more reliable than manually parsing the URL fragment.
        if supabase.auth.isSignInWithEmailLink(url.absoluteString) {
            // Post a notification to the SwiftUI App lifecycle to trigger navigation.
            NotificationCenter.default.post(name: .didReceivePasswordRecoveryURL, object: nil)

            // Task to process the session from the URL, which authenticates the user.
            Task {
                do {
                    _ = try await supabase.auth.session(from: url)
                } catch {
                    print("Error processing Supabase session from URL in AppDelegate: \(error.localizedDescription)")
                }
            }
        }

        return true
    }
}
