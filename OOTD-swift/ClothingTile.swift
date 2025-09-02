import SwiftUI

struct ClothingTile: View {
    let clothing: ClothingItem
    var isLarge: Bool = false

    var body: some View {
        VStack {
            if let imageUrl = clothing.images?.front, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.1).overlay(ProgressView())
                }
            } else {
                Color.gray.opacity(0.1).overlay(Image(systemName: "photo.on.rectangle"))
            }
        }
        .frame(width: isLarge ? 140 : 100, height: isLarge ? 140 : 100)
        .background(Color.gray.opacity(0.2))
        .clipped()
        .cornerRadius(12)
    }
}
