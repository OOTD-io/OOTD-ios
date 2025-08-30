import Foundation
import SwiftUI

@MainActor
class ClosetViewModel: ObservableObject {
    @Published var clothingItems = [ClothingItem]() {
        didSet {
            mapOutfits()
        }
    }
    @Published var generatedOutfits = [Outfit]() {
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
                if let base64String = dto.images["front"],
                   let data = Data(base64Encoded: base64String),
                   let uiImage = UIImage(data: data) {

                    let item = ClothingItem(
                        id: dto.id,
                        category: dto.type,
                        name: dto.subtype,
                        size: dto.size ?? "N/A",
                        image: Image(uiImage: uiImage),
                        sceneImage: nil
                    )
                    items.append(item)
                }
            }
            self.clothingItems = items
        } catch {
            errorMessage = "Failed to load your clothes. Please try again."
            print("Error fetching clothes: \(error)")
        }

        isLoadingClothes = false
    }

    func generateOutfits(weather: String) async {
        isLoadingOutfits = true
        do {
            let response = try await AIEngineService.shared.generateOutfit(weather: weather)
            self.generatedOutfits = response.outfits
        } catch {
            print("Error generating outfits: \(error)")
        }
        isLoadingOutfits = false
    }

    private func mapOutfits() {
        let clothingDict = Dictionary(uniqueKeysWithValues: clothingItems.map { ($0.id, $0) })

        let newViewModels = generatedOutfits.map { outfit -> OutfitViewModel in
            let tops = outfit.tops.compactMap { clothingDict[$0] }
            let bottoms = outfit.bottoms.compactMap { clothingDict[$0] }
            let shoes = outfit.shoes.compactMap { clothingDict[$0] }
            let outerwear = outfit.outerwear.compactMap { clothingDict[$0] }
            let accessories = outfit.accessories.compactMap { clothingDict[$0] }

            return OutfitViewModel(
                tops: tops,
                bottoms: bottoms,
                shoes: shoes,
                outerwear: outerwear,
                accessories: accessories
            )
        }

        self.outfitViewModels = newViewModels
    }
}
