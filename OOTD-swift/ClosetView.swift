import SwiftUI

struct ClosetView: View {
    @StateObject private var viewModel = ClosetViewModel()
    @ObservedObject var weatherManager: WeatherManager

    // Group clothing items by category for display
    private var clothingByCategory: [String: [ClothingItem]] {
        Dictionary(grouping: viewModel.clothingItems, by: { $0.type })
    }

    // Define a consistent order for categories
    private let categoryOrder: [String] = ["shirt", "pants", "shoes", "dress", "outerwear", "accessory"]

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading Your Closet...")
                    .padding()
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text("Error")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                    Button("Retry") {
                        viewModel.fetchData(weatherManager: weatherManager)
                    }
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
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
                    .padding(.vertical)
                }
            }
        }
        .onAppear {
            viewModel.fetchData(weatherManager: weatherManager)
        }
    }
}

// A tile representing a single generated outfit
struct OutfitTileView: View {
    let outfit: Outfit

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: outfit.image_url)) { image in
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
                // NavigationLink("See All →") {
                //     // The destination view needs to be updated to accept the new ClothingItem model
                //     // ClothingListView(title: title, items: items)
                // }
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(items) { item in
                        NavigationLink(destination: ClothingDetailView(clothing: item)) {
                            AsyncImage(url: URL(string: item.images.front)) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.1).overlay(ProgressView())
                            }
                            .frame(width: 110, height: 110)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// A dummy WeatherManager for previews
class PreviewWeatherManager: WeatherManager {
    override init() {
        super.init()
    }
}

#Preview {
    NavigationView {
        ClosetView(weatherManager: PreviewWeatherManager())
            .environmentObject(AuthenticationViewModel())
    }
}
