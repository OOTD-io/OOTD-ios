import SwiftUI

struct OutfitView: View {
    let outfits: [Outfit]
    @ObservedObject var closetViewModel: ClosetViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(outfits.indices, id: \.self) { index in
                        VStack(alignment: .leading) {
                            Text("Outfit \(index + 1)")
                                .font(.title2)
                                .fontWeight(.bold)

                            // We can improve this later to show a carousel of outfits
                            // For now, just show the first item of each category

                            if let topId = outfits[index].tops.first, let topItem = closetViewModel.clothingItems.first(where: { $0.id == topId }) {
                                ClothingNavigationTile(clothing: topItem, isLarge: true)
                            }

                            if let bottomId = outfits[index].bottoms.first, let bottomItem = closetViewModel.clothingItems.first(where: { $0.id == bottomId }) {
                                ClothingNavigationTile(clothing: bottomItem, isLarge: true)
                            }

                            if let shoeId = outfits[index].shoes.first, let shoeItem = closetViewModel.clothingItems.first(where: { $0.id == shoeId }) {
                                ClothingNavigationTile(clothing: shoeItem, isLarge: true)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Generated Outfits")
        }
    }
}
