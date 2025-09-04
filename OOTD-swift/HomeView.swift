//
//  SwiftUIView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/14/25.
//

import SwiftUI
import AuthenticationServices

struct HomeView<Content>: View where Content: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @State private var presentingLoginScreen = false
    @State private var presentingProfileScreen = false

    // Centralized state management for weather and outfits
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherManager = WeatherManager()
    @StateObject private var outfitViewModel = OutfitViewModel()

    @ViewBuilder var content: () -> Content
    
    enum Tab {
        case closet, add, profile
    }
    
    @State private var selectedTab: Tab = .closet

    var body: some View {
        ZStack(alignment: .bottom) {
            // This content view is from the original template, seems to be unused
            // when authenticated. Keeping it for now.
            content()

            // Main content based on selected tab
            Group {
                switch selectedTab {
                case .closet:
                    // The NavigationView now lives here, controlling the closet tab's stack.
                    NavigationView {
                        ScrollView {
                            // Weather Card is displayed once, at the top level.
                            if let weather = weatherManager.currentWeather {
                                WeatherCard(weather: weather)
                                    .padding(.vertical, 8)
                            } else {
                                ProgressView("Loading Weather…")
                                    .padding()
                            }

                            // Outfit Section is also at the top level.
                            OutfitSectionView(viewModel: outfitViewModel) {
                                // This is the onRegenerate closure
                                Task {
                                    if let weather = weatherManager.apiWeatherCondition {
                                        await outfitViewModel.forceRegenerateOutfits(for: weather)
                                    }
                                }
                            }

                            // ClosetView is now just for the clothes.
                            ClosetView()
                        }
                        // .navigationTitle is now on the ScrollView's content
                    }
                    .onAppear {
                        // This logic now lives in the HomeView, which is a more stable parent view.
                        locationManager.requestLocationPermission()
                    }
                    .onChange(of: locationManager.location) { location in
                        guard let location = location else { return }
                        Task {
                            await weatherManager.fetchWeather(for: location)
                        }
                    }
                    .onChange(of: weatherManager.apiWeatherCondition) { weatherCondition in
                        guard let weatherCondition = weatherCondition else { return }
                        Task {
                            await outfitViewModel.generateOutfitsIfNeeded(for: weatherCondition)
                        }
                    }

                case .add:
                    // The upload view is simple and doesn't need a NavigationView here.
                    // It's presented as a sheet from ClosetView.
                    // To make the '+' tab work, we can just show a placeholder or
                    // have it switch to the closet and open the sheet.
                    // For now, showing the view directly is fine.
                    ClothingUploadView()

                case .profile:
                    NavigationView {
                      UserProfileView()
                        .environmentObject(viewModel)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 80) // Add padding to prevent content from being hidden by tab bar
            
            // Custom Tab Bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard) // Prevents keyboard from pushing up tab bar
    }

    var customTabBar: some View {
        // This VStack ensures the tab bar is pushed to the very bottom of the screen.
        VStack(spacing: 0) {
            Spacer() // Pushes the HStack to the bottom
            HStack {
                Spacer()
                TabBarButton(icon: "tshirt.fill", text: "Closet", isSelected: selectedTab == .closet) {
                    selectedTab = .closet
                }
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
                Spacer()
                TabBarButton(icon: "person.crop.circle", text: "Profile", isSelected: selectedTab == .profile) {
                    selectedTab = .profile
                }
                .onReceive(NotificationCenter.default.publisher(for: ASAuthorizationAppleIDProvider.credentialRevokedNotification)) { _ in
                    // Handle sign out if needed
                }
                Spacer()
            }
            .padding(.top, 12)
            // The background now fills the entire bottom area, including the safe area.
            // The buttons themselves are padded by the safe area automatically.
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemBackground).ignoresSafeArea(edges: .bottom))
            .shadow(radius: 2)
        }
    }
}

// Helper view for the tab bar buttons
struct TabBarButton: View {
    let icon: String
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(text)
                    .font(.caption2)
            }
        }
        .foregroundColor(isSelected ? .blue : .gray)
    }
}

// Moved from ClosetView's file to be used here.
struct OutfitSectionView: View {
    @ObservedObject var viewModel: OutfitViewModel
    var onRegenerate: () -> Void // Callback to trigger regeneration

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("✨ Suggested Outfits")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: onRegenerate) {
                    Image(systemName: "arrow.clockwise")
                        .font(.headline)
                }
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal)

            if viewModel.isLoading {
                ProgressView("Generating outfits...")
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
            } else if viewModel.outfits.isEmpty {
                Text("No outfits generated yet. Add more clothes to your closet!")
                    .foregroundColor(.secondary)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(viewModel.outfits) { outfit in
                            NavigationLink(destination: OutfitDetailView(outfit: outfit)) {
                                OutfitTile(outfit: outfit)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }
}

// Moved from ClosetView's file to be used here.
struct OutfitTile: View {
    let outfit: Outfit

    var body: some View {
        AsyncImage(url: URL(string: outfit.image_url)) { image in
            image.resizable().aspectRatio(contentMode: .fill)
        } placeholder: {
            ProgressView()
        }
        .frame(width: 150, height: 200)
        .background(Color.gray.opacity(0.2))
        .clipped()
        .cornerRadius(12)
    }
}
