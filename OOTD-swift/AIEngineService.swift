import Foundation

class AIEngineService {
    static let shared = AIEngineService()
    private let baseURL = URL(string: "https://ootd-ai-engine-785972969271.us-central1.run.app/api")!

    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    private init() {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.jsonDecoder = decoder

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        self.jsonEncoder = encoder
    }

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
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorDetail = try? jsonDecoder.decode(APIErrorDetail.self, from: data) {
                throw APIError.serverError(message: "Error \(httpResponse.statusCode): \(errorDetail.detail)")
            }
            throw URLError(URLError.Code(rawValue: httpResponse.statusCode))
        }

        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            print("AIEngineService Decoding Error: \(error)")
            throw error
        }
    }

    // MARK: - API Functions

    func saveClothing(frontImage: Data, backImage: Data?, tagImage: Data?) async throws -> SaveClothingResponse {
        let url = baseURL.appendingPathComponent("/outfits/save-clothing")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = await getHeaders()

        let requestBody = SaveClothingRequest(
            frontImage: frontImage.base64EncodedString(),
            backImage: backImage?.base64EncodedString(),
            tagImage: tagImage?.base64EncodedString()
        )
        request.httpBody = try jsonEncoder.encode(requestBody)

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
        request.httpBody = try jsonEncoder.encode(requestBody)

        return try await performRequest(request: request)
    }
}
