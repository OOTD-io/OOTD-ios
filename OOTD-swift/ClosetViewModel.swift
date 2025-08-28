import Foundation
import SwiftUI

@MainActor
class ClosetViewModel: ObservableObject {
    @Published var clothingItems = [ClothingItem]()
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchClothes() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await AIEngineService.shared.getClothes()
            let dtos = response.clothes

            var items = [ClothingItem]()
            for dto in dtos {
                // For now, we only have one image. Let's assume it's the front.
                if let base64String = dto.images["front"],
                   let data = Data(base64Encoded: base64String),
                   let uiImage = UIImage(data: data) {

                    let item = ClothingItem(
                        id: dto.id,
                        category: dto.type,
                        name: dto.subtype,
                        size: dto.size ?? "N/A",
                        image: Image(uiImage: uiImage),
                        sceneImage: nil // We don't have this from the API yet
                    )
                    items.append(item)
                }
            }
            self.clothingItems = items
        } catch {
            errorMessage = "Failed to fetch clothes. Please try again."
            print("Error fetching clothes: \(error)")
        }

        isLoading = false
    }
}
