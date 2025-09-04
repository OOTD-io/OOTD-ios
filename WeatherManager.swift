//
//  WeatherManager.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/17/25.
//
import SwiftUI
@preconcurrency import WeatherKit
import CoreLocation

class WeatherManager: ObservableObject {
    private let service = WeatherService()
    
    @Published var currentWeather: CurrentWeather?
    @Published var apiWeatherCondition: WeatherCondition?

    func fetchWeather(for location: CLLocation) async {
        do {
            let weather = try await service.weather(for: location)
            let apiCondition = convertToAPIWeatherCondition(weather.currentWeather)

            await MainActor.run {
                self.currentWeather = weather.currentWeather
                self.apiWeatherCondition = apiCondition
            }
        } catch {
            print("Weather error:", error.localizedDescription)
        }
    }

    private func convertToAPIWeatherCondition(_ currentWeather: CurrentWeather) -> WeatherCondition {
        let temperatureF = currentWeather.temperature.converted(to: .fahrenheit).value

        let conditionString: String
        switch currentWeather.condition {
        case .clear, .mostlyClear, .hot:
            conditionString = "sunny"
        case .cloudy, .mostlyCloudy, .partlyCloudy, .foggy:
            conditionString = "cloudy"
        case .rain, .heavyRain, .drizzle, .hail, .strongStorms, .thunderstorms:
            conditionString = "rainy"
        case .snow, .heavySnow, .sleet, .wintryMix, .blizzard, .flurries:
            conditionString = "snowy"
        default:
            // Use a sensible default or handle unknown cases
            conditionString = "cloudy"
        }

        return WeatherCondition(temperature: temperatureF, condition: conditionString)
    }
}
