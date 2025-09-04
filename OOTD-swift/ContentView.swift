//
//  ContentView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 5/26/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    @State private var showPasswordReset = false
    @State private var recoveryURL: URL?

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
        .onReceive(NotificationCenter.default.publisher(for: .didReceivePasswordRecoveryURL)) { notif in
            if let url = notif.object as? URL {
                self.recoveryURL = url
                self.showPasswordReset = true
            }
        }
        .sheet(isPresented: $showPasswordReset) {
            // The user's guide shows passing the URL to the view.
            // Even if it's not used, it's good practice to follow the guide.
            ResetPasswordView(url: recoveryURL)
        }
    }
}

#Preview {
    ContentView()
}
