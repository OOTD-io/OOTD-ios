import Foundation
import SwiftUI

@MainActor
class ClosetViewModel: ObservableObject {
    @Published var clothingItems = [ClothingItem]() { didSet { mapOutfits() } }
    @Published var generatedOutfitsDTOs = [OutfitResponseDTO]() { didSet { mapOutfits() } }
    @Published var outfitViewModels = [OutfitViewModel]()

    @Published var isLoadingClothes = false
    @Published var isLoadingOutfits = false
    @Published var errorMessage: String?

    private let cacheManager = OutfitCacheManager.shared

    func fetchClothes() async {
        isLoadingClothes = true
        errorMessage = nil
        do {
            let response = try await AIEngineService.shared.getClothes()
            var items = [ClothingItem]()
            for dto in response.clothes {
                let imageURL = URL(string: dto.images["front"] ?? "")
                let item = ClothingItem(id: dto.id, category: dto.type, name: dto.subtype, size: dto.size ?? "N/A", imageURL: imageURL, sceneImage: nil)
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
        // 1. Try to load from cache first
        if let cached = cacheManager.loadOutfits(), !cached.isStale {
            print("[ClosetViewModel] Using fresh outfits from cache.")
            self.generatedOutfitsDTOs = cached.outfits
            return
        }

        // 2. If cache is stale or empty, fetch from API
        print("[ClosetViewModel] Cache is stale or empty. Fetching new outfits from API.")
        await forceRegenerateOutfits(weather: weather)
    }

    func forceRegenerateOutfits(weather: WeatherRequest) async {
        isLoadingOutfits = true
        do {
            let response = try await AIEngineService.shared.generateOutfit(weather: weather)
            self.generatedOutfitsDTOs = response.outfits
            // 3. Save new outfits to cache
            cacheManager.saveOutfits(response.outfits)
        } catch {
            print("Error generating outfits: \(error)")
        }
        isLoadingOutfits = false
    }

    private func mapOutfits() {
        guard !clothingItems.isEmpty else { return }
        let clothingDict = Dictionary(uniqueKeysWithValues: clothingItems.map { ($0.id, $0) })

        let newViewModels = generatedOutfitsDTOs.map { dto -> OutfitViewModel in
            let items = dto.clothingItemIds.compactMap { clothingDict[$0] }

            let tops = items.filter { $0.uiCategory == .top }
            let bottoms = items.filter { $0.uiCategory == .bottom }
            let dress = items.filter { $0.uiCategory == .dress }
            let shoes = items.filter { $0.uiCategory == .shoes }
            let outerwear = items.filter { $0.uiCategory == .outerwear }
            let accessories = items.filter { $0.uiCategory == .accessory }

            return OutfitViewModel(
                id: dto.id,
                tops: tops,
                bottoms: bottoms,
                dress: dress,
                shoes: shoes,
                outerwear: outerwear,
                accessories: accessories,
                compositeImageUrl: URL(string: dto.imageUrl ?? "")
            )
        }

        self.outfitViewModels = newViewModels
    }
}
