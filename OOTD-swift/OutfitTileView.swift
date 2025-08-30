import SwiftUI

struct OutfitTileView: View {
    let outfitViewModel: OutfitViewModel

    var body: some View {
        VStack {
            // Display the first item from each category.
            // The underlying model now supports multiple items, so this
            // could be updated to a carousel or ZStack in the future.

            if let topItem = outfitViewModel.tops.first {
                topItem.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
            }

            if let bottomItem = outfitViewModel.bottoms.first {
                bottomItem.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 60)
            }

            if let shoeItem = outfitViewModel.shoes.first {
                shoeItem.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
