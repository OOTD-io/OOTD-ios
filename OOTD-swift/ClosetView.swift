import SwiftUI
import WeatherKit

struct ClosetView: View {
    @ObservedObject var viewModel: ClosetViewModel
    let weather: CurrentWeather?
    let weatherError: String?

    // This computed property will derive the available categories
    private var availableCategories: [ClothingCategory] {
        let categories = Set(viewModel.clothingItems.map { $0.uiCategory })
        // A specific, logical order for the UI
        let desiredOrder: [ClothingCategory] = [.top, .bottom, .dress, .outerwear, .shoes, .accessory, .unknown]
        return categories.sorted { cat1, cat2 in
            guard let firstIndex = desiredOrder.firstIndex(of: cat1),
                  let secondIndex = desiredOrder.firstIndex(of: cat2) else {
                return false
            }
            return firstIndex < secondIndex
        }
    }

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
                    ForEach(availableCategories, id: \.self) { category in
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
                    Text("\(emoji(for: category)) \(category.rawValue)")
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
        case .top: "👕"
        case .bottom: "👖"
        case .dress: "👗"
        case .shoes: "👟"
        case .accessory: "👜"
        case .outerwear: "🧥"
        case .unknown: "✨"
        }
    }
}

#Preview {
    ClosetView(viewModel: ClosetViewModel(), weather: nil, weatherError: "Could not load weather.")
}
