//
//  AIEngineClient.swift
//  OOTD-swift
//
//  Created by Jules on 8/26/25.
//

import Foundation
import UIKit
import Supabase

class AIEngineClient {
    static let shared = AIEngineClient()
    private let baseURL = URL(string: "https://ootd-ai-engine-785972969271.us-central1.run.app/api/outfits")!

    private init() {}

    enum APIError: Error {
        case missingAuthToken
        case invalidResponse
        case requestFailed(Error)
    }

    private func createAuthenticatedRequest(for url: URL, method: String = "GET") async throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let token = try? await supabase.auth.session.accessToken else {
            throw APIError.missingAuthToken
        }

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }

    func saveClothing(frontImage: UIImage, backImage: UIImage?, tagImage: UIImage?) async throws -> SaveClothingResponse {
        let url = baseURL.appendingPathComponent("save-clothing")
        var request = try await createAuthenticatedRequest(for: url, method: "POST")

        let requestPayload = SaveClothingRequest(
            frontImage: frontImage.jpegData(compressionQuality: 0.8)!.base64EncodedString(),
            backImage: backImage?.jpegData(compressionQuality: 0.8)?.base64EncodedString(),
            tagImage: tagImage?.jpegData(compressionQuality: 0.8)?.base64EncodedString()
        )

        request.httpBody = try JSONEncoder().encode(requestPayload)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            // TODO: Log error message from response data
            throw APIError.invalidResponse
        }

        return try JSONDecoder().decode(SaveClothingResponse.self, from: data)
    }

    func getClothes(limit: Int? = nil) async throws -> GetClothesResponse {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent("clothes"), resolvingAgainstBaseURL: true)!
        if let limit = limit {
            urlComponents.queryItems = [URLQueryItem(name: "limit", value: "\(limit)")]
        }

        let request = try await createAuthenticatedRequest(for: urlComponents.url!, method: "GET")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            // TODO: Log error message from response data
            throw APIError.invalidResponse
        }

        return try JSONDecoder().decode(GetClothesResponse.self, from: data)
    }

    func generateOutfit(weather: WeatherInfo) async throws -> GenerateOutfitResponse {
        let url = baseURL.appendingPathComponent("generate")
        var request = try await createAuthenticatedRequest(for: url, method: "POST")

        let requestPayload = GenerateOutfitRequest(weather: weather)
        request.httpBody = try JSONEncoder().encode(requestPayload)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            // TODO: Log error message from response data
            throw APIError.invalidResponse
        }

        return try JSONDecoder().decode(GenerateOutfitResponse.self, from: data)
    }
}

// MARK: - Data Models for /clothes

struct GetClothesResponse: Codable {
    let clothes: [ClothingItem]
    let totalCount: Int
    let userId: String

    enum CodingKeys: String, CodingKey {
        case clothes
        case totalCount = "total_count"
        case userId = "user_id"
    }
}

struct ClothingItem: Codable, Identifiable {
    let id: String
    let userId: String
    let type: String
    let subtype: String
    let color: [String: String]
    let pattern: String?
    let material: String?
    let brand: String?
    let size: String?
    let weatherSuitability: [String: String]?
    let occasion: [String]?
    let genderPresenting: String
    let lastWorn: String
    let imageConfidenceScore: Double?
    let images: [String: String]

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_uuid"
        case type, subtype, color, pattern, material, brand, size, occasion, images
        case weatherSuitability = "weather_suitability"
        case genderPresenting = "gender_presenting"
        case lastWorn = "last_worn"
        case imageConfidenceScore = "image_confidence_score"
    }
}

// MARK: - Data Models for /generate

struct GenerateOutfitRequest: Codable {
    let weather: WeatherInfo
}

struct WeatherInfo: Codable {
    let temperature: Double
    let condition: String
    let windSpeed: Double
    let uvIndex: Int
}

struct GenerateOutfitResponse: Codable {
    let userId: String
    let totalOutfitsGenerated: Int
    let outfits: [Outfit]

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case totalOutfitsGenerated = "total_outfits_generated"
        case outfits
    }
}

struct Outfit: Codable, Identifiable {
    let id = UUID()
    let items: [ClothingItem]

    enum CodingKeys: String, CodingKey {
        case items
    }
}


// MARK: - Data Models for /save-clothing

struct SaveClothingRequest: Codable {
    let frontImage: String
    let backImage: String?
    let tagImage: String?

    enum CodingKeys: String, CodingKey {
        case frontImage = "front_image"
        case backImage = "back_image"
        case tagImage = "tag_image"
    }
}

struct SaveClothingResponse: Codable {
    let itemId: String
    let message: String
    let analysis: ClothingAnalysisData

    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case message
        case analysis
    }
}

struct ClothingAnalysisData: Codable {
    let type: String
    let subtype: String
    let color: [String: String]
    let pattern: String?
    let material: String?
    let brand: String?
    let size: String?
    let weatherSuitability: [String: String]? // Simplified for now
    let occasion: [String]?
    let genderPresenting: String
    let imageConfidenceScore: Double?

    enum CodingKeys: String, CodingKey {
        case type, subtype, color, pattern, material, brand, size, occasion
        case weatherSuitability = "weather_suitability"
        case genderPresenting = "gender_presenting"
        case imageConfidenceScore = "image_confidence_score"
    }
}
