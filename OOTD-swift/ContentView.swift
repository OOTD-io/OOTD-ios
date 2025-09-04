//
//  ContentView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 5/26/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        // ContentView is now just a container for the AuthenticatedView flow.
        // All deep link and sheet presentation logic has been moved to the @main App struct.
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
