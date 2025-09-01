//
//  ClothingNavigationTile.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/17/25.
//
import SwiftUI

struct ClothingNavigationTile: View {
    let clothing: ClothingItem
    let isLarge: Bool?

    var body: some View {
        NavigationLink(destination: ClothingDetailView(clothing: clothing)) {
            ClothingTile(clothing: clothing, isLarge: isLarge ?? false )
        }
        .foregroundStyle(.primary)
    }
}
