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
    @StateObject private var authViewModel = AuthenticationViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .preferredColorScheme(.light)
                .onOpenURL { url in
                    Task {
                        do {
                            try await supabase.auth.session(from: url)
                        } catch {
                            print("Error handling deep link: \(error.localizedDescription)")
                        }
                    }
                }
        }
    }
}
