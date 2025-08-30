//
//  ClosetViewModel.swift
//  OOTD-swift
//
//  Created by Riyad Sarsour on 8/30/25.
//

import Foundation
import SwiftUI

@MainActor
class ClosetViewModel: ObservableObject {
    @Published var clothingItems = [ClothingItem]() {
        didSet {
            mapOutfits()
        }
    }
    @Published var generatedOutfitsDTOs = [OutfitResponseDTO]() {
        didSet {
            mapOutfits()
        }
    }
    @Published var outfitViewModels = [OutfitViewModel]()

    @Published var isLoadingClothes = false
    @Published var isLoadingOutfits = false
    @Published var errorMessage: String?

    func fetchClothes() async {
        isLoadingClothes = true
        errorMessage = nil

        do {
            let response = try await AIEngineService.shared.getClothes()
            var items = [ClothingItem]()
            for dto in response.clothes {
                let imageURL = URL(string: dto.images["front"] ?? "")

                let item = ClothingItem(
                    id: dto.id,
                    category: dto.type,
                    name: dto.subtype,
                    size: dto.size ?? "N/A",
                    imageURL: imageURL,
                    sceneImage: nil
                )
                items.append(item)
            }
            self.clothingItems = items
        } catch {
            errorMessage = "Failed to load your clothes. Please try again."
            print("Error fetching clothes: \(error)")
        }

        isLoadingClothes = false
    }

    func generateOutfits(weather: WeatherRequest) async {
        isLoadingOutfits = true
        do {
            let response = try await AIEngineService.shared.generateOutfit(weather: weather)
            print("[ClosetViewModel] Received \(response.outfits.count) outfits from API.")
            self.generatedOutfitsDTOs = response.outfits
        } catch {
            print("[ClosetViewModel] Error generating outfits: \(error)")
        }
        isLoadingOutfits = false
    }

    private func mapOutfits() {
        print("[ClosetViewModel] mapOutfits called.")
        print("[ClosetViewModel] clothingItems count: \(clothingItems.count)")
        print("[ClosetViewModel] generatedOutfitsDTOs count: \(generatedOutfitsDTOs.count)")

        guard !clothingItems.isEmpty else {
            print("[ClosetViewModel] clothingItems is empty, cannot map outfits yet.")
            return
        }
        let clothingDict = Dictionary(uniqueKeysWithValues: clothingItems.map { ($0.id, $0) })

        let newViewModels = generatedOutfitsDTOs.map { dto -> OutfitViewModel in
            let items = dto.clothingItemIds.compactMap { clothingDict[$0] }

            let tops = items.filter { $0.uiCategory == .tops }
            let bottoms = items.filter { $0.uiCategory == .bottoms }
            let dress = items.filter { $0.uiCategory == .dress }
            let shoes = items.filter { $0.uiCategory == .shoes }
            let outerwear = items.filter { $0.uiCategory == .outerwear }
            let accessories = items.filter { $0.uiCategory == .accessories }

            return OutfitViewModel(
                id: dto.id,
                tops: tops,
                bottoms: bottoms,
                dress: dress,
                shoes: shoes,
                outerwear: outerwear,
                accessories: accessories,
                compositeImageUrl: URL(string: dto.imageUrl)
            )
        }

        print("[ClosetViewModel] Created \(newViewModels.count) outfit view models.")
        self.outfitViewModels = newViewModels
    }
}
