//
//  SwiftUIView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/14/25.
//

import SwiftUI
import AuthenticationServices



struct HomeView<Content>: View where Content: View{
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var presentingLoginScreen = false
    @State private var presentingProfileScreen = false
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherManager = WeatherManager()
    
    @ViewBuilder var content: () -> Content
    
    enum Tab {
        case closet, add, profile
    }
    
    @State private var selectedTab: Tab = .closet



    var body: some View {
        
        ZStack(alignment: .bottom) {
            content()

            // Main content based on selected tab
            Group {
                switch selectedTab {
                case .closet:
//                    VStack {
                        // Weather View
                    ScrollView() {
                        // Weather View
                        if let weather = weatherManager.currentWeather {
                            WeatherCard(weather: weather)
                                .padding(.vertical, 8)
                        } else {
                            Text("Loading weather…")
                                .foregroundColor(.gray)
                                .onAppear {
                                    if let loc = locationManager.location {
                                        Task {
                                            await weatherManager.fetchWeather(for: loc)
                                        }
                                    }
                                }
                        }
                        ClosetView()
                    }
                    
                case .add:
                    ClothingUploadView()
                case .profile:
                    NavigationView {
                      UserProfileView()
                        .environmentObject(viewModel)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            
            // Custom Tab Bar
            HStack {
                Spacer()

                Button(action: {
                    selectedTab = .closet
                }) {
                    VStack {
                        Image(systemName: "tshirt.fill")
                        Text("Closet")
                            .font(.caption2)
                    }
                }
                .foregroundColor(selectedTab == .closet ? .blue : .gray)

                Spacer()

                Button(action: {
                    
                    selectedTab = .add
                }) {
                    ZStack {
                        Circle()
                            .foregroundColor(.blue)
                            .frame(width: 56, height: 56)
                            .shadow(radius: 4)

                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .bold))
                    }
                }
//                            .offset(y: -20)

                Spacer()

                Button(action: {
                    selectedTab = .profile
                }) {
                    VStack {
                        Image(systemName: "person.crop.circle")
                        Text("Profile")
                        .font(.caption2)
                    }
                }
                .foregroundColor(selectedTab == .profile ? .blue : .gray)
                .onReceive(NotificationCenter.default.publisher(for: ASAuthorizationAppleIDProvider.credentialRevokedNotification)) { event in
//                signOut()
                  if let userInfo = event.userInfo, let info = userInfo["info"] {
                    print(info)
                  }
                }

                Spacer()
            }
            .padding(.vertical, 10)
            .background(Color.white.ignoresSafeArea(edges: .bottom))
//            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .gray.opacity(0.2), radius: 5, y: -2)
            .offset(y:30)
        }
    }
}

// Placeholder Views
//struct ClosetView: View {
//    var body: some View {
//        Text("Closet")
//    }
//}

struct AddView: View {
    var body: some View {
        Text("Add New Item")
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile")
    }
}


#Preview {
//    HomeView(nil, nil)
}
