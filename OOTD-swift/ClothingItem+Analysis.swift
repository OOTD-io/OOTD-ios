//
//  ClothingItem+Analysis.swift
//  OOTD-swift
//
//  Created by Jules on 8/26/25.
//

import Foundation

struct AnalyzedClothingItem: Identifiable, Codable {
    let id = UUID()
    let type: String
    let category: String
    let color: ColorInfo
    let attributes: ClothingAttributes
    let weatherSuitability: WeatherSuitability
    let occasions: [String]
    let brand: String?

    enum CodingKeys: String, CodingKey {
        case type, category, color, attributes, occasions, brand
        case weatherSuitability = "weather_suitability"
    }
}
