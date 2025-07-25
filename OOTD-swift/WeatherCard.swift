//
//  WeatherCard.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/17/25.
//

import SwiftUI
import WeatherKit

struct WeatherCard: View {
    let weather: CurrentWeather

    var body: some View {
        ZStack {
            // Gradient background
            RoundedRectangle(cornerRadius: 24)
                .fill(backgroundGradient(for: weather.condition))
                .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 8)

            HStack(spacing: 20) {
                // Weather icon with soft glow
                Image(systemName: iconName(for: weather.condition))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .blur(radius: 1)
                    )

                VStack(alignment: .leading, spacing: 8) {
                    // Temperature: °F + °C
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("\(format(weather.temperature, to: .fahrenheit))°F")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                        Text("·")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.6))

                        Text("\(format(weather.temperature, to: .celsius))°C")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    // Condition
                    Text(weather.condition.description)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))

                    // Feels like
                    Text("Feels like \(format(weather.apparentTemperature, to: .fahrenheit))°F / \(format(weather.apparentTemperature, to: .celsius))°C")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()
            }
            .padding()
        }
        .frame(height: 140)
        .padding(.horizontal)
    }

    private func format(_ temp: Measurement<UnitTemperature>, to unit: UnitTemperature) -> Int {
        return Int(temp.converted(to: unit).value.rounded())
    }

    private func iconName(for condition: WeatherCondition) -> String {
        switch condition {
            case .clear: return "sun.max.fill"
            case .cloudy: return "cloud.fill"
            case .mostlyCloudy: return "cloud.sun.fill"
            case .partlyCloudy: return "cloud.sun"
            case .rain, .drizzle: return "cloud.rain.fill"
            case .snow: return "cloud.snow.fill"
            case .thunderstorms: return "cloud.bolt.rain.fill"
            case .foggy: return "cloud.fog.fill"
            default: return "cloud"
        }
    }

    private func backgroundGradient(for condition: WeatherCondition) -> LinearGradient {
        switch condition {
        case .clear:
            return LinearGradient(
                colors: [Color.orange.opacity(0.9), Color.yellow.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cloudy, .mostlyCloudy, .partlyCloudy:
            return LinearGradient(
                colors: [Color.gray.opacity(0.8), Color.black.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .rain, .drizzle, .foggy:
            return LinearGradient(
                colors: [Color.gray.opacity(0.7), Color.blue.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .snow:
            return LinearGradient(
                colors: [Color.white.opacity(0.8), Color.gray.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .thunderstorms:
            return LinearGradient(
                colors: [Color.purple.opacity(0.7), Color.gray.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [Color.gray.opacity(0.5), Color.black.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
