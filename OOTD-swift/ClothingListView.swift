//
//  ClothingListView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/16/25.
//

import SwiftUI

struct ClothingListView: View {
    let title: String
    @State private var items: [ClothingItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    @Environment(\.dismiss) var dismiss

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 20)], spacing: 20) {
                        ForEach(items) { item in
                            // Assuming ClothingNavigationTile can be initialized with the new ClothingItem
                            // and can handle fetching the image from the 'images' dictionary.
                            // This might require changes to ClothingNavigationTile.
                            ClothingNavigationTile(clothing: item, isLarge: false)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(title)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // Handle dismiss (via pop)
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(Color.primary) // Or your custom color
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
//                    .background(
//                        RoundedRectangle(cornerRadius: 10)
//                            .fill(Color(UIColor.systemGray5))
//                    )
                }
            }
        }
        .onAppear(perform: fetchClothes)
    }

    private func fetchClothes() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let response = try await AIEngineClient.shared.getClothes()
                DispatchQueue.main.async {
                    self.items = response.clothes
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("Failed to fetch clothes: \(error)")
                }
            }
        }
    }
}
