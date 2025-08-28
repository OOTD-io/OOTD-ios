//
//  ClosetView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/15/25.
//

import SwiftUI

struct ClosetView: View {
    @ObservedObject var viewModel: ClosetViewModel

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading your closet...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                ScrollView {
                    VStack {
                        // Suggested Outfits (we'll implement this later)
                        HStack {
                            Spacer()
                            VStack(alignment: .leading) {
                                HStack {
                                    Spacer()
                                    Text("Suggested Outfits")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                            }
                            Spacer()
                        }

                        // Clothing sections
                        clothingSection(title: "👕 Tops", category: "tops")
                        clothingSection(title: "👖 Bottoms", category: "bottoms")
                        clothingSection(title: "👟 Shoes", category: "shoes")
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchClothes()
            }
        }
    }

    @ViewBuilder
    private func clothingSection(title: String, category: String) -> some View {
        let items = viewModel.clothingItems.filter { $0.category.lowercased() == category }

        if !items.isEmpty {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    NavigationLink("See All →") {
                        ClothingListView(title: title, items: items)
                    }
                    .font(.subheadline)
                    .padding(.trailing, 10)
                    .foregroundColor(.black)
                }
                .padding(.leading, 15)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(items) { item in
                            ClothingNavigationTile(clothing: item, isLarge: false)
                        }
                    }
                    .padding(.horizontal, 15)
                }
            }
            .padding(.vertical, 10)
        }
    }
}

#Preview {
    ClosetView(viewModel: ClosetViewModel())
}
