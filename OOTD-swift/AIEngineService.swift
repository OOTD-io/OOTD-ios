import Foundation

class AIEngineService {
    static let shared = AIEngineService()
    private let baseURL = URL(string: "https://ootd-ai-engine-785972969271.us-central1.run.app/api")!

    private init() {}

    // MARK: - Private Helpers
    private func getHeaders() async -> [String: String] {
        var headers = ["Content-Type": "application/json"]
        do {
            let session = try await supabase.auth.session
            headers["Authorization"] = "Bearer \(session.accessToken)"
        } catch {
            print("Could not get Supabase session for headers: \(error)")
        }
        return headers
    }

    private func performRequest<T: Decodable>(request: URLRequest) async throws -> T {
        print("[AIEngineService] Performing request to: \(request.url?.absoluteString ?? "N/A")")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            print("[AIEngineService] Error: Did not receive a valid HTTP response.")
            throw URLError(.badServerResponse)
        }

        print("[AIEngineService] Received HTTP status code: \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No response body"
            print("[AIEngineService] Error: Server returned status \(httpResponse.statusCode). Body: \(errorBody)")
            // Try to decode an error message from the body
            if let errorDetail = try? JSONDecoder().decode(APIErrorDetail.self, from: data) {
                throw APIError.serverError(message: errorDetail.detail)
            }
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }

        print("[AIEngineService] Request successful. Attempting to decode response.")
        return try JSONDecoder().decode(T.self, from: data)
    }

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


    // MARK: - API Functions

    func saveClothing(frontImage: Data, backImage: Data?, tagImage: Data?) async throws -> SaveClothingResponse {
        let url = baseURL.appendingPathComponent("/outfits/save-clothing")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = await getHeaders()

        let requestBody = SaveClothingRequest(
            front_image: frontImage.base64EncodedString(),
            back_image: backImage?.base64EncodedString(),
            tag_image: tagImage?.base64EncodedString()
        )
        request.httpBody = try JSONEncoder().encode(requestBody)

        return try await performRequest(request: request)
    }

    func fetchClothing() async throws -> GetClothesResponse {
        let url = baseURL.appendingPathComponent("/outfits/clothes")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = await getHeaders()

        return try await performRequest(request: request)
    }

    func generateOutfits(temperature: Double, condition: String) async throws -> GenerateOutfitResponse {
        let url = baseURL.appendingPathComponent("/outfits/generate")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = await getHeaders()

        let weatherInput = WeatherInput(temperature: temperature, condition: condition)
        let requestBody = GenerateOutfitRequest(weather: weatherInput)
        request.httpBody = try JSONEncoder().encode(requestBody)

        return try await performRequest(request: request)
    }
}
