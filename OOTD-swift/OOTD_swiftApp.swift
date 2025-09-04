//
//  OOTD_swiftApp.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 5/26/25.
//

import SwiftUI
import Supabase

@main
struct OOTD_swiftApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthenticationViewModel()

    @State private var recoveryURL: URL?
    @State private var showPasswordReset = false

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.authenticationState == .authenticated {
                    HomeView { EmptyView() }
                        .environmentObject(authViewModel)
                } else {
                    AuthenticationView()
                        .environmentObject(authViewModel)
                }
            }
            .preferredColorScheme(.light)
            // MARK: 1) onOpenURL — reliable when the app is running / cold-started
            .onOpenURL { url in
                handleIncomingURL(url)
            }
            // MARK: 2) Also check a persisted pending URL (fallback)
            .onAppear {
                if let pending = UserDefaults.standard.string(forKey: "pendingRecoveryURL"),
                   let url = URL(string: pending) {
                    // Clear stored pending value
                    UserDefaults.standard.removeObject(forKey: "pendingRecoveryURL")
                    Task { await processRecoveryURL(url) }
                }
            }
            .sheet(isPresented: $showPasswordReset) {
                ResetPasswordView(url: recoveryURL)
            }
        }
    }

    // Called from onOpenURL
    private func handleIncomingURL(_ url: URL) {
        print("OOTDApp.onOpenURL received: \(url)")
        guard url.scheme == "ootd", url.host == "auth-callback" else { return }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let isRecoveryInQuery = components?.queryItems?.contains(where: { $0.name == "type" && $0.value == "recovery" }) ?? false
        let isRecoveryInFragment = components?.fragment?.contains("type=recovery") ?? false

        // New: treat 'code' + pendingPasswordReset as recovery
        let hasCode = components?.queryItems?.contains(where: { $0.name == "code" }) ?? false
        let hasPendingReset = isPendingPasswordResetRecent()

        let treatAsRecovery = isRecoveryInQuery || isRecoveryInFragment || (hasCode && hasPendingReset)

        if treatAsRecovery {
            print("Detected recovery link (isRecoveryInQuery:\(isRecoveryInQuery) isRecoveryInFragment:\(isRecoveryInFragment) hasCode:\(hasCode) pendingReset:\(hasPendingReset)). Processing as recovery.")
            Task { await processRecoveryURL(url) }
        } else {
            Task {
                do {
                    _ = try await supabase.auth.session(from: url)
                    print("Processed normal auth session from URL.")
                } catch {
                    print("Error processing normal session: \(error)")
                }
            }
        }
    }

    // Helper: check pending reset within 30 minutes (adjust as you like)
    private func isPendingPasswordResetRecent(maxAgeSeconds: TimeInterval = 30 * 60) -> Bool {
        guard let str = UserDefaults.standard.string(forKey: "pendingPasswordReset"),
              let data = str.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let at = obj["at"] as? TimeInterval else {
            return false
        }
        let age = Date().timeIntervalSince1970 - at
        let result = age >= 0 && age <= maxAgeSeconds
        print("isPendingPasswordResetRecent check: age=\(age)s, isRecent=\(result)")
        return result
    }

    // Create session + then show reset UI
    private func processRecoveryURL(_ url: URL) async {
        do {
            print("Creating session from recovery URL...")
            _ = try await supabase.auth.session(from: url)
            print("Session created for recovery.")
            // Clear pending marker
            UserDefaults.standard.removeObject(forKey: "pendingPasswordReset")
            await MainActor.run {
                self.recoveryURL = url
                self.showPasswordReset = true
            }
        } catch {
            print("Failed to create session from recovery URL: \(error). Persisting pendingRecoveryURL for retry.")
            // fallback persist raw url too
            UserDefaults.standard.set(url.absoluteString, forKey: "pendingRecoveryURL")
        }
    }
}
