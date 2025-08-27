//
//  ClothingTile.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/16/25.
//

import SwiftUI

struct ClothingTile: View {
    let item: ClothingItem
    var isLarge: Bool = false

    var body: some View {
        VStack {
            image(from: item.images["front"])
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: isLarge ? 140 : 100, height: isLarge ? 140 : 100)
                .background(Color.gray.opacity(0.2))
                .clipped()
                .cornerRadius(12)

            Text("\(item.type) - \(item.subtype)")
                .font(.caption)
                .lineLimit(1)
        }
    }

    private func image(from base64String: String?) -> Image {
        guard let base64String = base64String,
              let data = Data(base64Encoded: base64String),
              let uiImage = UIImage(data: data) else {
            return Image(systemName: "photo")
        }
        return Image(uiImage: uiImage)
    }
}
