import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var generatedOutfits: [Outfit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var shouldShowOutfits = false

    func generateOutfits(weather: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await AIEngineService.shared.generateOutfit(weather: weather)
            self.generatedOutfits = response.outfits
            self.shouldShowOutfits = true
        } catch {
            errorMessage = "Failed to generate outfits. Please try again."
            print("Error generating outfits: \(error)")
        }

        isLoading = false
    }
}
