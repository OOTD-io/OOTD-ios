//
//  Models.swift
//  OOTD-swift
//
//  Created by Jules on 9/3/25.
//

import Foundation

// MARK: - Get Clothes Response
struct ClothesResponse: Codable {
    let clothes: [ClothingItem]
    let total_count: Int
    let user_id: String
}

struct ClothingItem: Codable, Identifiable {
    let id: String
    let type: String
    let subtype: String
    let color: String
    let pattern: String
    let material: String
    let brand: String?
    let size: String?
    let weather_suitability: WeatherSuitability
    let occasion: [String]
    let gender_presenting: String
    let last_worn: String?
    let image_confidence_score: Double
    let images: ClothingImages
}

struct WeatherSuitability: Codable {
    let hot: Bool
    let warm: Bool
    let cool: Bool
    let cold: Bool
}

struct ClothingImages: Codable {
    let front: String
    let back: String?
    let tag: String?
}

// MARK: - Save Clothing Request
struct SaveClothingRequest: Codable {
    let front_image: String
    let back_image: String?
    let tag_image: String?
}

// MARK: - Generate Outfit Request
struct GenerateOutfitRequest: Codable {
    let weather: APIWeatherCondition
}

struct APIWeatherCondition: Codable {
    let temperature: Double  // Fahrenheit
    let condition: String    // "sunny", "rainy", "cloudy", "snowy"
}


// MARK: - Generate Outfit Response
struct OutfitResponse: Codable {
    let user_id: String
    let total_outfits_generated: Int
    let outfits: [Outfit]
}

struct Outfit: Codable, Identifiable {
    let id = UUID()
    let category: String
    let clothing_item_ids: [String]
    let image_url: String
    let image_path: String
    let individual_item_images: [String]

    private enum CodingKeys: String, CodingKey {
        case category, clothing_item_ids, image_url, image_path, individual_item_images
    }
}
