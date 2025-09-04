//
//  ContentView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 5/26/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appRouter: AppRouter
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        // If the app was opened via a password reset link, show the ResetPasswordView first.
        // Otherwise, show the normal authenticated view flow.
        if appRouter.showResetPasswordView {
            NavigationView {
                ResetPasswordView()
            }
        } else {
            NavigationView {
                AuthenticatedView {
                    Image("ootd-icon")
                    .resizable()
                    .frame(width: 300 , height: 300)
                    Text("Welcome to OOTD!")
                    .font(.title)
                    Text("You need to be logged in to use this app.")
                } content: {
                    Spacer()
                }
            }
            .onAppear {
                locationManager.requestLocationPermission()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppRouter())
}
