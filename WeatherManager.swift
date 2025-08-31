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

    func fetchWeather(for location: CLLocation) async {
        do {
            let weather = try await service.weather(for: location)
            DispatchQueue.main.async {
                self.currentWeather = weather.currentWeather
            }
        } catch {
            print("Weather error:", error.localizedDescription)
        }
    }
}
