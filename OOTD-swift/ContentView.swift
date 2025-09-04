//
//  ContentView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 5/26/25.
//

import SwiftUI

struct ContentView: View {
    // This view no longer handles routing. It's just the main content view.
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
    }
}

#Preview {
    ContentView()
}
