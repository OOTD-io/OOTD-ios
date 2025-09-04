//
//  ClosetView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/15/25.
//

import SwiftUI

struct ClosetView: View {
    @StateObject private var closetViewModel = ClosetViewModel()
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
        // NOTE: The NavigationView, WeatherCard, and OutfitSection have been moved to HomeView
        // to fix navigation and state management bugs. This view is now only responsible
        // for displaying the clothing items.
        VStack {
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
            }
        }
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
