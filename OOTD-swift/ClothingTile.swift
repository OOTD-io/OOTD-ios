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
            AsyncImage(url: URL(string: item.images.front)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: isLarge ? 140 : 100, height: isLarge ? 140 : 100)
            .background(Color.gray.opacity(0.2))
            .clipped()
            .cornerRadius(12)

            Text(item.subtype)
                .font(.caption)
                .lineLimit(1)
        }
    }
}
