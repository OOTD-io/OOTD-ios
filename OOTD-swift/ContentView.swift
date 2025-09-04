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
        .sheet(isPresented: $appRouter.showResetPasswordView) {
            // The ResetPasswordView should probably be in its own NavigationView
            // to have a proper title bar and structure.
            NavigationView {
                ResetPasswordView()
            }
        }
    }
}

#Preview {
    ContentView()
}
