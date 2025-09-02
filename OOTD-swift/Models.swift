import Foundation

// This file contains the data models (structs) used to communicate
// with the OOTD AI Engine API. They are based on the provided API documentation.

// MARK: - Endpoint 1: Save Clothing Item

struct SaveClothingRequest: Codable {
    let front_image: String
    let back_image: String?
    let tag_image: String?
}

struct SaveClothingResponse: Codable {
    let item_id: String
    let message: String
    let analysis: ClothingAnalysis
}

struct ClothingAnalysis: Codable {
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
    let image_confidence_score: Double
}

// MARK: - Endpoint 2: Get User's Clothing Items

struct GetClothesResponse: Codable {
    let clothes: [ClothingItem]
    let total_count: Int
    let user_id: String
}

struct ClothingItem: Codable, Identifiable {
    let id: String
    let type: String
    let subtype: String
    let color: String
    let pattern: String?
    let material: String?
    let brand: String?
    let size: String?
    let weather_suitability: WeatherSuitability?
    let occasion: [String]?
    let gender_presenting: String?
    let last_worn: String?
    let image_confidence_score: Double?
    let images: ClothingImages
}

struct ClothingImages: Codable {
    let front: String
    let back: String?
}

struct WeatherSuitability: Codable {
    let hot: Bool
    let warm: Bool
    let cool: Bool
    let cold: Bool
}

// MARK: - Endpoint 3: Generate Outfit Recommendations

struct GenerateOutfitRequest: Codable {
    let weather: WeatherInput
}

struct WeatherInput: Codable {
    let temperature: Double
    let condition: String
}

struct GenerateOutfitResponse: Codable {
    let user_id: String
    let total_outfits_generated: Int
    let outfits: [Outfit]
}

struct Outfit: Codable, Identifiable {
    var id: String { clothing_item_ids.joined(separator: "-") }
    let category: String
    let clothing_item_ids: [String]
    let image_url: String
    let individual_item_images: [String]
}
