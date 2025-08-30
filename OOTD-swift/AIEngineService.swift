import Foundation
import Supabase

// MARK: - API Service
class AIEngineService {
    static let shared = AIEngineService()
    // NOTE: Using the actual URL, not the placeholder from the docs
    private let baseURL = URL(string: "https://ootd-ai-engine-785972969271.us-central1.run.app/api")!

    private func getAccessToken() async throws -> String {
        let session = try await supabase.auth.session
        return session.accessToken
    }

    func generateOutfit(weather: WeatherRequest) async throws -> GenerateOutfitResponse {
        let url = baseURL.appendingPathComponent("/outfits/generate")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let accessToken = try await getAccessToken()
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(GenerateOutfitRequest(weather: weather))

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            let errorDetail = String(data: data, encoding: .utf8)
            if let response = response as? HTTPURLResponse {
                print("Error response from generateOutfit: \(response.statusCode) - \(errorDetail ?? "No details")")
            } else {
                print("Error response from generateOutfit: Invalid response type - \(errorDetail ?? "No details")")
            }
            throw APIError.serverError
        }

        do {
            return try JSONDecoder().decode(GenerateOutfitResponse.self, from: data)
        } catch {
            print("Decoding error in generateOutfit: \(error)")
            throw APIError.decodingError
        }
    }

    func getClothes() async throws -> GetClothesResponse {
        let url = baseURL.appendingPathComponent("/outfits/clothes")
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
        } catch {
            print("Decoding error in getClothes: \(error)")
            throw APIError.decodingError
        }
    }

    func saveClothing(item: ClothingItemRequest) async throws -> SaveClothingResponse {
        let url = baseURL.appendingPathComponent("/outfits/save-clothing")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let accessToken = try await getAccessToken()
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(item)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw APIError.serverError
        }

        do {
            return try JSONDecoder().decode(SaveClothingResponse.self, from: data)
        } catch {
            print("Decoding error in saveClothing: \(error)")
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

// MARK: - /generate Models
struct WeatherRequest: Codable {
    let temperature: Double
    let condition: String
}

struct GenerateOutfitRequest: Codable {
    let weather: WeatherRequest
}

struct OutfitResponseDTO: Codable, Identifiable {
    var id: String { clothingItemIds.joined(separator: "-") }
    let category: String
    let clothingItemIds: [String]
    let imageUrl: String
    let imagePath: String
    let individualItemImages: [String]

    enum CodingKeys: String, CodingKey {
        case category, imageUrl, imagePath
        case clothingItemIds = "clothing_item_ids"
        case individualItemImages = "individual_item_images"
    }
}

struct GenerateOutfitResponse: Codable {
    let userId: String
    let totalOutfitsGenerated: Int
    let outfits: [OutfitResponseDTO]

    enum CodingKeys: String, CodingKey {
        case outfits
        case userId = "user_id"
        case totalOutfitsGenerated = "total_outfits_generated"
    }
}

// MARK: - Shared Models
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
    // userUuid is not in the new documentation for this object, removing
    let type: String
    let subtype: String
    let color: String
    let pattern: String?
    let material: String?
    let brand: String?
    let size: String?
    let weatherSuitability: WeatherSuitability?
    let occasion: [String]?
    let genderPresenting: String?
    let lastWorn: String?
    let imageConfidenceScore: Double?
    let images: [String: String]

    enum CodingKeys: String, CodingKey {
        case id, type, subtype, color, pattern, material, brand, size, occasion, images
        case weatherSuitability = "weather_suitability"
        case genderPresenting = "gender_presenting"
        case lastWorn = "last_worn"
        case imageConfidenceScore = "image_confidence_score"
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
    let weatherSuitability: WeatherSuitability?
    let occasion: [String]
    let genderPresenting: String
    let imageConfidenceScore: Double? // Added from docs

    enum CodingKeys: String, CodingKey {
        case type, subtype, color, pattern, material, brand, size, occasion
        case weatherSuitability = "weather_suitability"
        case genderPresenting = "gender_presenting"
        case imageConfidenceScore = "image_confidence_score"
    }
}

struct SaveClothingResponse: Codable {
    let itemId: String
    let message: String
    let analysis: AnalysisResult

    enum CodingKeys: String, CodingKey {
        case message, analysis
        case itemId = "item_id"
    }
}
