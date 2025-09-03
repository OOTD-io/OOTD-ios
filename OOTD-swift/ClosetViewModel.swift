import Foundation
import WeatherKit

@MainActor
class ClosetViewModel: ObservableObject {
    @Published var clothingItems: [ClothingItem] = []
    @Published var generatedOutfits: [Outfit] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let aiEngineService = AIEngineService.shared

    func fetchData(weather: CurrentWeather?) {
        isLoading = true
        errorMessage = nil

        Task {
            // Fetch clothes first, as they are needed for generation
            do {
                let response = try await aiEngineService.fetchClothing()
                self.clothingItems = response.clothes
            } catch {
                self.errorMessage = "Failed to fetch closet items: \(error.localizedDescription)"
                self.isLoading = false
                return
            }

            // Then, generate outfits if we have weather
            guard let weather = weather else {
                self.isLoading = false
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
