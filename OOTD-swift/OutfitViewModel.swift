//
//  OutfitViewModel.swift
//  OOTD-swift
//
//  Created by Jules on 9/3/25.
//

import SwiftUI
import Supabase

@MainActor
class OutfitViewModel: ObservableObject {
    @Published var outfits: [Outfit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Simple in-memory cache
    private var cachedOutfits: [Outfit]?

    func generateOutfitsIfNeeded(for weather: WeatherCondition) async {
        // If we have cached outfits, use them
        if let cachedOutfits = cachedOutfits {
            self.outfits = cachedOutfits
            return
        }

        isLoading = true
        errorMessage = nil

        let requestBody = GenerateOutfitRequest(weather: weather)

        do {
            let session = try await supabase.auth.session
            let token = session.accessToken

            let url = URL(string: "https://ootd-ai-engine-785972969271.us-central1.run.app/api/outfits/generate")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(requestBody)

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.serverError
            }

            if httpResponse.statusCode == 201 {
                let decoder = JSONDecoder()
                let outfitResponse = try decoder.decode(OutfitResponse.self, from: data)
                self.outfits = outfitResponse.outfits
                self.cachedOutfits = outfitResponse.outfits // Cache the result
            } else if httpResponse.statusCode == 404 {
                self.errorMessage = "We couldn't find enough clothes to generate outfits for this weather. Try adding more items to your closet!"
            }
            else {
                let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
                self.errorMessage = "Failed to generate outfits. \(errorBody)"
                print("Error generating outfits: \(httpResponse.statusCode) - \(errorBody)")
            }

        } catch {
            self.errorMessage = error.localizedDescription
            print("Error generating outfits: \(error)")
        }

        isLoading = false
    }
}
