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
        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        print("AppDelegate received URL: \(url.absoluteString)")

        guard url.scheme == "ootd", url.host == "auth-callback" else { return false }

        // If it's a recovery link, persist it as a fallback
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let isRecovery = components?.queryItems?.contains(where: { $0.name == "type" && $0.value == "recovery" }) ?? false

        if isRecovery {
            print("AppDelegate detected recovery link. Persisting fallback and posting notification.")
            // Persist a fallback so the SwiftUI root can pick it up if it missed the Notification
            UserDefaults.standard.set(url.absoluteString, forKey: "pendingRecoveryURL")

            // also post notification (in case observer already exists)
            NotificationCenter.default.post(name: .didReceivePasswordRecoveryURL, object: url)

            return true
        }

        // otherwise, process session normally
        Task {
            do {
                _ = try await supabase.auth.session(from: url)
                print("Supabase session processed from AppDelegate.")
            } catch {
                print("Error processing session in AppDelegate: \(error)")
            }
        }

        return true
    }
}
