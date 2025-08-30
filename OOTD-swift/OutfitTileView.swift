import SwiftUI

struct OutfitTileView: View {
    let outfitViewModel: OutfitViewModel

    var body: some View {
        AsyncImage(url: outfitViewModel.compositeImageUrl) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            ProgressView()
        }
        .frame(minHeight: 150)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .clipped()
    }
}
