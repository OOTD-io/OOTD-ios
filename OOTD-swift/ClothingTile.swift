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
            if let sceneName = item.sceneImage {
                SceneKitView(modelName: sceneName)
                    .frame(width: isLarge ? 140 : 100, height: isLarge ? 140 : 100)
                    .clipShape(.buttonBorder)
                //                .frame(height: 300)
                //                .cornerRadius(12)
                //                .padding()
                //                .background(.clear)
            } else {
                AsyncImage(url: item.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: isLarge ? 140 : 100, height: isLarge ? 140 : 100)
                .background(Color.gray.opacity(0.2))
                .clipped()
                .cornerRadius(12)
            }
//            item.image
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: isLarge ? 140 : 100, height: isLarge ? 140 : 100)
//                .background(Color.gray.opacity(0.2))
//                .clipped()
//                .cornerRadius(12)

            Text(item.name)
                .font(.caption)
                .lineLimit(1)
        }
    }
}
