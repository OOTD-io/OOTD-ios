//
//  OutfitDetailView.swift
//  OOTD-swift
//
//  Created by Jules on 9/3/25.
//

import SwiftUI

struct OutfitDetailView: View {
    let outfit: Outfit
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Main outfit image
                AsyncImage(url: URL(string: outfit.image_url)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                    default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 400)
                            .cornerRadius(12)
                            .overlay(ProgressView())
                    }
                }

                Text("Items in this Outfit")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                // Individual item images
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(outfit.individual_item_images, id: \.self) { imageUrl in
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 100, height: 120)
                            .background(Color.gray.opacity(0.2))
                            .clipped()
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(outfit.category.capitalized + " Outfit")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(Color.primary)
                }
            }
        }
    }
}
