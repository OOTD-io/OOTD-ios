import Foundation

@MainActor
class ClosetViewModel: ObservableObject {
    @Published var clothingItems: [ClothingItem] = []
    @Published var generatedOutfits: [Outfit] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let aiEngineService = AIEngineService.shared

    func fetchData(weatherManager: WeatherManager) {
        isLoading = true
        errorMessage = nil

        Task {
            // Fetch clothes first
            do {
                let response = try await aiEngineService.fetchClothing()
                self.clothingItems = response.clothes
            } catch {
                self.errorMessage = "Failed to fetch closet items: \(error.localizedDescription)"
                self.isLoading = false // Stop loading on error
                return
            }

            // Then, generate outfits
            guard let weather = weatherManager.currentWeather else {
                self.errorMessage = "Weather data is not available to generate outfits."
                self.isLoading = false // Stop loading
                return
            }

            let temp = weather.temperature.value
            let condition = weather.condition.description.lowercased()

            do {
                let response = try await aiEngineService.generateOutfits(temperature: temp, condition: condition)
                self.generatedOutfits = response.outfits
            } catch {
                self.errorMessage = "Failed to generate outfits: \(error.localizedDescription)"
            }

            self.isLoading = false
        }
    }
}
