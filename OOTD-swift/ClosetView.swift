import SwiftUI
import WeatherKit

struct ClosetView: View {
    @ObservedObject var viewModel: ClosetViewModel
    let weather: CurrentWeather?
    let weatherError: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 1. Weather Section
                if let weather = weather {
                    WeatherCard(weather: weather)
                        .padding(.horizontal)
                } else if let weatherError = weatherError {
                    Text(weatherError)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    HStack {
                        Spacer()
                        Text("Loading Weather...")
                        ProgressView()
                        Spacer()
                    }
                    .padding()
                }

                // 2. Generated Outfits Section
                if viewModel.isLoadingOutfits {
                    HStack {
                        Spacer()
                        ProgressView("Generating Outfits...")
                        Spacer()
                    }
                } else if !viewModel.outfitViewModels.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Generated Outfits")
                            .font(.title2).bold()
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                            ForEach(viewModel.outfitViewModels) { outfitVM in
                                OutfitTileView(outfitViewModel: outfitVM)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // 3. Individual Clothing Sections
                if viewModel.isLoadingClothes {
                     HStack {
                        Spacer()
                        ProgressView("Loading Your Closet...")
                        Spacer()
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // Use CaseIterable to avoid hardcoding sections
                    ForEach(ClothingCategory.allCases, id: \.self) { category in
                        clothingSection(for: category)
                    }
                }
            }
            .padding(.vertical)
        }
    }

    @ViewBuilder
    private func clothingSection(for category: ClothingCategory) -> some View {
        let items = viewModel.clothingItems.filter { $0.uiCategory == category }

        if !items.isEmpty {
            VStack(alignment: .leading) {
                HStack {
                    // A simple way to get an emoji, can be improved
                    let emoji = emoji(for: category)
                    Text("\(emoji) \(category.rawValue)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    NavigationLink("See All →") {
                        ClothingListView(title: category.rawValue, items: items)
                    }
                    .font(.subheadline)
                }
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(items) { item in
                            ClothingNavigationTile(clothing: item, isLarge: false)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 10)
        }
    }

    private func emoji(for category: ClothingCategory) -> String {
        switch category {
        case .tops: "👕"
        case .bottoms: "👖"
        case .shoes: "👟"
        case .accessories: "👜"
        case .outerwear: "🧥"
        case .other: "✨"
        }
    }
}

#Preview {
    ClosetView(viewModel: ClosetViewModel(), weather: nil, weatherError: "Could not load weather.")
}
