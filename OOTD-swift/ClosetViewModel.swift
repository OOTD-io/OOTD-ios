import Foundation

@MainActor
class ClosetViewModel: ObservableObject {
    @Published var clothingItems: [ClothingItem] = []
    @Published var generatedOutfits: [Outfit] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let aiEngineService = AIEngineService.shared

    func fetchData(weatherManager: WeatherManager) {
        print("[ClosetViewModel] fetchData called.")
        isLoading = true
        errorMessage = nil

        Task {
            // Fetch clothes first
            do {
                let response = try await aiEngineService.fetchClothing()
                self.clothingItems = response.clothes
                print("[ClosetViewModel] Successfully fetched \(response.clothes.count) clothing items.")
            } catch {
                let errorDesc = "Failed to fetch closet items: \(error.localizedDescription)"
                print("[ClosetViewModel] \(errorDesc)")
                self.errorMessage = errorDesc
                self.isLoading = false // Stop loading on error
                return
            }

            // Then, generate outfits
            guard let weather = weatherManager.currentWeather else {
                let errorDesc = "Weather data is not available to generate outfits."
                print("[ClosetViewModel] \(errorDesc)")
                self.errorMessage = errorDesc
                self.isLoading = false // Stop loading
                return
            }

            let temp = weather.temperature.value
            let condition = weather.condition.description.lowercased()
            print("[ClosetViewModel] Generating outfits with temp: \(temp), condition: \(condition)")

            do {
                let response = try await aiEngineService.generateOutfits(temperature: temp, condition: condition)
                self.generatedOutfits = response.outfits
                print("[ClosetViewModel] Successfully generated \(response.outfits.count) outfits.")
            } catch {
                let errorDesc = "Failed to generate outfits: \(error.localizedDescription)"
                print("[ClosetViewModel] \(errorDesc)")
                self.errorMessage = errorDesc
            }

            self.isLoading = false
        }
    }
}
