//
//  ClosetView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/15/25.
//

import SwiftUI

struct ClosetView: View {
    @StateObject private var closetViewModel = ClosetViewModel()
    @StateObject private var outfitViewModel = OutfitViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherManager = WeatherManager()
    @State private var showingUploadSheet = false

    private func icon(for category: String) -> String {
        switch category {
        case "Tops": return "👕"
        case "Bottoms": return "👖"
        case "Outwear": return "🧥"
        case "Shoes": return "👟"
        default: return "👔"
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Weather Card and Outfit Section
                    WeatherCard(weather: weatherManager.currentWeather)
                        .padding(.horizontal)

                    OutfitSectionView(viewModel: outfitViewModel)

                    // Closet Section
                    if closetViewModel.isLoading {
                        ProgressView("Loading your closet...")
                    } else if let errorMessage = closetViewModel.errorMessage {
                        Text("Error: \(errorMessage)").foregroundColor(.red).padding()
                    } else {
                        ForEach(closetViewModel.categories, id: \.self) { category in
                            if let items = closetViewModel.clothingItems[category], !items.isEmpty {
                                ClothingSectionView(
                                    title: "\(icon(for: category)) \(category)",
                                    items: items
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Closet")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingUploadSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingUploadSheet, onDismiss: {
                Task { await closetViewModel.fetchClothing() }
            }) {
                ClothingUploadView()
            }
            .onAppear {
                Task {
                    await closetViewModel.fetchClothing()
                    locationManager.requestLocationPermission()
                }
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
        }
    }
}

struct OutfitSectionView: View {
    @ObservedObject var viewModel: OutfitViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("✨ Suggested Outfits")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)

            if viewModel.isLoading {
                ProgressView("Generating outfits...")
                    .frame(height: 150)
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
            } else if viewModel.outfits.isEmpty {
                Text("No outfits generated yet. Check back soon!")
                    .foregroundColor(.secondary)
                    .frame(height: 150)
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

struct ClothingSectionView: View {
    let title: String
    let items: [ClothingItem]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                NavigationLink("See All →") {
                    ClothingListView(title: title, items: items)
                }
                .font(.subheadline)
                .foregroundColor(.black)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(items) { item in
                        ClothingNavigationTile(clothing: item, isLarge: false)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    ClosetView()
}
