import SwiftUI
import WeatherKit
import CoreLocation

@MainActor
class WeatherManager: ObservableObject {
    private let service = WeatherService()
    
    @Published var currentWeather: CurrentWeather?
    @Published var errorMessage: String?

    func fetchWeather(for location: CLLocation) async {
        print("[WeatherManager] Fetching weather for location: \(location.coordinate.latitude),\(location.coordinate.longitude)")
        errorMessage = nil

        do {
            let weather = try await service.weather(for: location)
            self.currentWeather = weather.currentWeather
        } catch {
            print("Weather error:", error.localizedDescription)
            self.errorMessage = "Failed to fetch weather. Please try again."
        }
    }
}
