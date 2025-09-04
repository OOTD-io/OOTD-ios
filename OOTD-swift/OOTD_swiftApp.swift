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
        // quick sanity check and only handle our scheme
        guard url.scheme == "ootd", url.host == "auth-callback" else { return }

        // If it's a recovery link, process it
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let isRecovery = components?.queryItems?.contains(where: { $0.name == "type" && $0.value == "recovery" }) ?? false
        if isRecovery {
            Task {
                await processRecoveryURL(url)
            }
        } else {
            // other auth flows: you may want to call supabase.session(from:) too
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

    // Create session + then show reset UI
    private func processRecoveryURL(_ url: URL) async {
        do {
            print("Creating session from recovery URL...")
            _ = try await supabase.auth.session(from: url)
            print("Session created for recovery.")
            // show reset UI on main actor
            await MainActor.run {
                self.recoveryURL = url
                self.showPasswordReset = true
            }
        } catch {
            // If session creation fails, persist URL as fallback so AppDelegate/next launch can pick it up
            print("Failed to create session from recovery URL: \(error). Persisting pendingRecoveryURL for retry.")
            UserDefaults.standard.set(url.absoluteString, forKey: "pendingRecoveryURL")
        }
    }
}
