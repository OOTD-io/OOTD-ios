import SwiftUI

struct ClothingTile: View {
    let item: ClothingItem
    var isLarge: Bool = false

    var body: some View {
        VStack {
            if let sceneName = item.sceneImage {
                SceneKitView(modelName: sceneName)
                    .frame(width: isLarge ? 140 : 100, height: isLarge ? 140 : 100)
                    .clipShape(.buttonBorder)
            } else {
                AsyncImage(url: item.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: isLarge ? 140 : 100, height: isLarge ? 140 : 100)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .clipped()
            }

            Text(item.name)
                .font(.caption)
                .lineLimit(1)
        }
    }
}
