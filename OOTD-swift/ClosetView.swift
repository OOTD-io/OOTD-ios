import SwiftUI
import WeatherKit

struct ClosetView: View {
    @ObservedObject var viewModel: ClosetViewModel
    let weather: CurrentWeather?

    var body: some View {
        ScrollView {
            VStack {
                // 1. Weather Section
                if let weather = weather {
                    WeatherCard(weather: weather)
                        .padding()
                } else {
                    // A placeholder while weather is loading
                    HStack {
                        Text("Loading Weather...")
                        ProgressView()
                    }
                    .padding()
                }

                // 2. Generated Outfits Section
                if viewModel.isLoadingOutfits {
                    ProgressView("Generating Outfits...")
                } else if !viewModel.outfitViewModels.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Generated Outfits")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        // Grid for outfits
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                            ForEach(viewModel.outfitViewModels) { outfitVM in
                                OutfitTileView(outfitViewModel: outfitVM)
                            }
                        }
                        .padding()
                    }
                }

                // 3. Individual Clothing Sections
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    clothingSection(title: "👕 Tops", category: .tops)
                    clothingSection(title: "👖 Bottoms", category: .bottoms)
                    clothingSection(title: "👟 Shoes", category: .shoes)
                    clothingSection(title: "🧥 Outerwear", category: .outerwear)
                    clothingSection(title: "👜 Accessories", category: .accessories)
                }
            }
        }
    }

    @ViewBuilder
    private func clothingSection(title: String, category: ClothingCategory) -> some View {
        let items = viewModel.clothingItems.filter { $0.uiCategory == category }

        if !items.isEmpty {
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
                    .padding(.trailing, 10)
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
            .padding(.vertical, 10)
        }
    }
}

#Preview {
    ClosetView(viewModel: ClosetViewModel(), weather: nil)
}
