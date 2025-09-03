import SwiftUI

struct ClosetView: View {
    @ObservedObject var viewModel: ClosetViewModel
    @ObservedObject var weatherManager: WeatherManager

    private var clothingByCategory: [String: [ClothingItem]] {
        Dictionary(grouping: viewModel.clothingItems, by: { $0.type })
    }

    // Define a consistent order for categories
    private let categoryOrder: [String] = ["shirt", "pants", "shoes", "dress", "outerwear", "accessory"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Weather Card
                if let weather = weatherManager.currentWeather {
                    WeatherCard(weather: weather)
                        .padding(.horizontal)
                } else if let errorMessage = weatherManager.errorMessage {
                    VStack {
                        Text("Weather Error").font(.headline).foregroundColor(.red)
                        Text(errorMessage).font(.caption).foregroundColor(.red)
                    }
                    .padding()
                } else {
                    HStack {
                        Spacer()
                        ProgressView("Loading Weather...")
                        Spacer()
                    }
                    .padding()
                }

                // Main Content
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Loading Your Closet...")
                        Spacer()
                    }
                    .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text("Error").font(.headline).foregroundColor(.red)
                        Text(errorMessage).font(.caption).foregroundColor(.red)
                    }
                    .padding()
                } else {
                    // Suggested Outfits Section
                    VStack(alignment: .leading) {
                        Text("Suggested Outfits")
                            .font(.title.bold())
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                if viewModel.generatedOutfits.isEmpty {
                                    Text("No outfits to suggest right now.")
                                        .foregroundColor(.secondary)
                                        .padding()
                                        .frame(height: 100)
                                } else {
                                    ForEach(viewModel.generatedOutfits) { outfit in
                                        OutfitTileView(outfit: outfit)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Clothing Categories Section
                    ForEach(categoryOrder, id: \.self) { category in
                        if let items = clothingByCategory[category], !items.isEmpty {
                            ClothingCategoryRow(title: category.capitalized, items: items)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Closet")
        .navigationBarHidden(true)
    }
}

// A tile representing a single generated outfit
struct OutfitTileView: View {
    let outfit: Outfit

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: outfit.imageUrl)) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.1).overlay(ProgressView())
            }
            .frame(width: 150, height: 150)
            .cornerRadius(12)

            Text(outfit.category.capitalized)
                .font(.headline)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// A row for a single category of clothing items
struct ClothingCategoryRow: View {
    let title: String
    let items: [ClothingItem]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.title2.bold())
                Spacer()
                NavigationLink("See All →") {
                     ClothingListView(title: title, items: items)
                }
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(items) { item in
                        NavigationLink(destination: ClothingDetailView(clothing: item)) {
                            if let imageUrl = item.images?.front, let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray.opacity(0.1).overlay(ProgressView())
                                }
                            } else {
                                Color.gray.opacity(0.1).overlay(Image(systemName: "photo.on.rectangle"))
                            }
                        }
                        .frame(width: 110, height: 110)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .clipped()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
