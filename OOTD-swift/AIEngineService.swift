import Foundation
import Supabase

// MARK: - API Service
class AIEngineService {
    static let shared = AIEngineService()
    private let baseURL = URL(string: "https://ootd-ai-engine-785972969271.us-central1.run.app")!

    private func getAccessToken() async throws -> String {
        let session = try await supabase.auth.session
        return session.accessToken
    }

    // UPDATED
    func generateOutfit(weather: WeatherRequest) async throws -> GenerateOutfitResponse {
        let url = baseURL.appendingPathComponent("/api/outfits/generate")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let accessToken = try await getAccessToken()
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let requestBody = GenerateOutfitRequest(weather: weather)
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            // Enhanced error logging
            let errorDetail = String(data: data, encoding: .utf8)
            print("Error response from generateOutfit: \(httpResponse.statusCode) - \(errorDetail ?? "No details")")
            throw APIError.serverError
        }

        do {
            return try JSONDecoder().decode(GenerateOutfitResponse.self, from: data)
        } catch let decodingError {
            print("Decoding error in generateOutfit: \(decodingError)")
            throw APIError.decodingError
        }
    }

    func getClothes() async throws -> GetClothesResponse {
        let url = baseURL.appendingPathComponent("/api/outfits/clothes")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let accessToken = try await getAccessToken()
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.serverError
        }
        do {
            return try JSONDecoder().decode(GetClothesResponse.self, from: data)
        } catch let decodingError {
            print("Decoding error in getClothes: \(decodingError)")
            throw APIError.decodingError
        }
    }

    func saveClothing(item: ClothingItemRequest) async throws -> SaveClothingResponse {
        let url = baseURL.appendingPathComponent("/api/outfits/save-clothing")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let accessToken = try await getAccessToken()
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(item)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            let errorDetail = String(data: data, encoding: .utf8)
            print("Error response from server: \(errorDetail ?? "No details")")
            throw APIError.serverError
        }
        do {
            return try JSONDecoder().decode(SaveClothingResponse.self, from: data)
        } catch let decodingError {
            print("Decoding error in saveClothing: \(decodingError)")
            throw APIError.decodingError
        }
    }
}

// MARK: - API Models

enum APIError: Error {
    case invalidURL
    case serverError
    case decodingError
}

// MARK: - /generate Models (UPDATED)
struct WeatherRequest: Codable {
    let temperature: Double
    let condition: String
}

struct GenerateOutfitRequest: Codable {
    let weather: WeatherRequest
}

struct OutfitResponseDTO: Codable, Identifiable {
    var id: String { clothingItemIds.joined(separator: "-") } // Create a stable ID
    let category: String
    let clothingItemIds: [String]
    let imageUrl: String
    let imagePath: String
    let individualItemImages: [String]

    enum CodingKeys: String, CodingKey {
        case category
        case clothingItemIds = "clothing_item_ids"
        case imageUrl = "image_url"
        case imagePath = "image_path"
        case individualItemImages = "individual_item_images"
    }
}

struct GenerateOutfitResponse: Codable {
    let userId: String
    let totalOutfitsGenerated: Int
    let outfits: [OutfitResponseDTO]

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case totalOutfitsGenerated = "total_outfits_generated"
        case outfits
    }
}

// MARK: - Shared Models (UPDATED)
struct WeatherSuitability: Codable {
    let hot: Bool
    let warm: Bool
    let cool: Bool
    let cold: Bool
}

// MARK: - /clothes Models
struct GetClothesResponse: Codable {
    let clothes: [ClothingItemDTO]
    let totalCount: Int
    let userId: String

    enum CodingKeys: String, CodingKey {
        case clothes
        case totalCount = "total_count"
        case userId = "user_id"
    }
}

struct ClothingItemDTO: Codable, Identifiable {
    let id: String
    let userUuid: String
    let type: String
    let subtype: String
    let color: String
    let pattern: String?
    let material: String?
    let brand: String?
    let size: String?
    let weatherSuitability: WeatherSuitability? // UPDATED
    let occasion: [String]?
    let genderPresenting: String?
    let lastWorn: String?
    let imageConfidenceScore: Double?
    let images: [String: String] // These are URLs

    enum CodingKeys: String, CodingKey {
        case id
        case userUuid = "user_uuid"
        case type, subtype, color, pattern, material, brand, size
        case weatherSuitability = "weather_suitability"
        case occasion
        case genderPresenting = "gender_presenting"
        case lastWorn = "last_worn"
        case imageConfidenceScore = "image_confidence_score"
        case images
    }
}

// MARK: - /save-clothing Models
struct ClothingItemRequest: Codable {
    let frontImage: String
    let backImage: String?
    let tagImage: String?

    enum CodingKeys: String, CodingKey {
        case frontImage = "front_image"
        case backImage = "back_image"
        case tagImage = "tag_image"
    }
}

struct AnalysisResult: Codable {
    let type: String
    let subtype: String
    let color: String
    let pattern: String?
    let material: String?
    let brand: String?
    let size: String?
    let weatherSuitability: WeatherSuitability? // UPDATED
    let occasion: [String]
    let genderPresenting: String

    enum CodingKeys: String, CodingKey {
        case type, subtype, color, pattern, material, brand, size
        case weatherSuitability = "weather_suitability"
        case occasion
        case genderPresenting = "gender_presenting"
    }
}

struct SaveClothingResponse: Codable {
    let itemId: String
    let message: String
    let analysis: AnalysisResult

    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case message, analysis
    }
}
