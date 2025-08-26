//
//  AIEngineClient.swift
//  OOTD-swift
//
//  Created by Jules on 8/26/25.
//

import Foundation
import UIKit

class AIEngineClient {
    static let shared = AIEngineClient()
    private let baseURL = URL(string: "https://ootd-ai-engine-785972969271.us-central1.run.app/api")!

    private init() {}

    func describeClothing(images: [UIImage]) async throws -> DescribeResponse {
        let describeURL = baseURL.appendingPathComponent("describe")

        let base64Images = images.compactMap { $0.jpegData(compressionQuality: 0.8)?.base64EncodedString() }

        guard !base64Images.isEmpty else {
            throw URLError(.badURL) // Or a custom error
        }

        let requestPayload = DescribeRequest(images: base64Images)
        let requestData = try JSONEncoder().encode(requestPayload)

        if let jsonString = String(data: requestData, encoding: .utf8) {
            print("Request JSON: \(jsonString)")
        }

        var request = URLRequest(url: describeURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let describeResponse = try JSONDecoder().decode(DescribeResponse.self, from: data)
        return describeResponse
    }
}

// MARK: - Data Models

struct DescribeRequest: Codable {
    let images: [String]
}

struct DescribeResponse: Codable {
    let status: String
    let message: String
    let imageCount: Int

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case imageCount = "image_count"
    }
}

struct ClothingItemAnalysis: Codable {
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

struct ColorInfo: Codable {
    let primary: String
    let secondary: String?
    let pattern: String?
}

struct ClothingAttributes: Codable {
    let material: String?
    let style: String?
    let fit: String?
    let neckline: String?
    let sleeves: String?
}

struct WeatherSuitability: Codable {
    let temperature: TemperatureRange
    let conditions: [String]
    let seasons: [String]
}

struct TemperatureRange: Codable {
    let min: Int
    let max: Int
}
