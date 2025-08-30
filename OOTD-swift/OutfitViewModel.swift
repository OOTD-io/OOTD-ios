//
//  OutfitViewModel.swift
//  OOTD-swift
//
//  Created by Riyad Sarsour on 8/30/25.
//

import Foundation

struct OutfitViewModel: Identifiable {
    let id: String
    let tops: [ClothingItem]
    let bottoms: [ClothingItem]
    let shoes: [ClothingItem]
    let outerwear: [ClothingItem]
    let accessories: [ClothingItem]
    let compositeImageUrl: URL?
}
