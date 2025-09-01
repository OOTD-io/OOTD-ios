import SwiftUI

struct ClothingTile: View {
    let clothing: ClothingItem
    var isLarge: Bool = false

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: clothing.images.front)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.1).overlay(ProgressView())
            }
            .frame(width: isLarge ? 140 : 100, height: isLarge ? 140 : 100)
            .background(Color.gray.opacity(0.2))
            .clipped()
            .cornerRadius(12)

            Text(clothing.subtype.capitalized)
                .font(.caption)
                .lineLimit(1)
        }
    }
}
