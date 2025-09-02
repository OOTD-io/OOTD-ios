import Foundation

// MARK: - General API Structures

struct APIErrorDetail: Decodable {
    let detail: String
}

enum APIError: Error, LocalizedError {
    case serverError(message: String)

    var errorDescription: String? {
        switch self {
        case .serverError(let message):
            return message
        }
    }
}

// MARK: - Endpoint 1: Save Clothing Item

struct SaveClothingRequest: Codable {
    let frontImage: String
    let backImage: String?
    let tagImage: String?
}

struct SaveClothingResponse: Codable {
    let itemId: String
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
    let weatherSuitability: WeatherSuitability
    let occasion: [String]
    let genderPresenting: String
    let imageConfidenceScore: Double
}

// MARK: - Endpoint 2: Get User's Clothing Items

struct GetClothesResponse: Codable {
    let clothes: [ClothingItem]
    let totalCount: Int
    let userId: String
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
    let weatherSuitability: WeatherSuitability
    let occasion: [String]
    let genderPresenting: String
    let lastWorn: String?
    let imageConfidenceScore: Double
    let images: ClothingImages
}

struct ClothingImages: Codable {
    let front: String
    let back: String?
    let tag: String?
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
    let userId: String
    let totalOutfitsGenerated: Int
    let outfits: [Outfit]
}

struct Outfit: Codable, Identifiable {
    // The API doesn't provide a stable ID, so we generate one for SwiftUI's purposes.
    let id = UUID()
    let category: String
    let clothingItemIds: [String]
    let imageUrl: String
    let imagePath: String
    let individualItemImages: [String]

    private enum CodingKeys: String, CodingKey {
        case category, clothingItemIds, imageUrl, imagePath, individualItemImages
    }
}
