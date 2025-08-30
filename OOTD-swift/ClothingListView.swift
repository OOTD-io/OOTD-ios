//
//  ClothingListView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/16/25.
//

import SwiftUI

struct ClothingListView: View {
    let title: String
    let items: [ClothingItem]
    @State private var selectedItem: ClothingItem? = nil
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 20)], spacing: 20) {
                ForEach(items) { item in
                    ClothingNavigationTile(clothing: item, isLarge: true)
                }
            }
            .padding()
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
//        .sheet(item: $selectedItem) {
//            ClothingDetailView(item: $0)
//        }
    }
}
