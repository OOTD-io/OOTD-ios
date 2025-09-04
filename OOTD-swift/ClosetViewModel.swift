//
//  ClosetViewModel.swift
//  OOTD-swift
//
//  Created by Jules on 9/3/25.
//

import SwiftUI
import Supabase

@MainActor
class ClosetViewModel: ObservableObject {
    @Published var clothingItems: [String: [ClothingItem]] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Define the order of categories
    let categories = ["Tops", "Bottoms", "Outwear", "Other"]

    func fetchClothing() async {
        isLoading = true
        errorMessage = nil

        do {
            let session = try await Supabase.client.auth.session
            let token = session.accessToken

            let url = URL(string: "https://ootd-ai-engine-785972969271.us-central1.run.app/api/outfits/clothes")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.serverError
            }

            if httpResponse.statusCode == 404 {
                clothingItems = [:]
                isLoading = false
                return
            }

            guard httpResponse.statusCode == 200 else {
                let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("Server error: \(httpResponse.statusCode), body: \(errorBody)")
                throw APIError.serverError
            }

            let decoder = JSONDecoder()
            let clothesResponse = try decoder.decode(ClothesResponse.self, from: data)

            // Group the clothes
            let groupedItems = Dictionary(grouping: clothesResponse.clothes) { item -> String in
                switch item.type.lowercased() {
                case "shirt", "t-shirt", "blouse", "top", "sweater", "hoodie":
                    return "Tops"
                case "pants", "jeans", "shorts", "skirt", "trousers":
                    return "Bottoms"
                case "jacket", "coat", "vest", "blazer":
                    return "Outwear"
                case "shoes":
                    return "Shoes"
                default:
                    return "Other"
                }
            }

            self.clothingItems = groupedItems

        } catch {
            self.errorMessage = "We couldn't load your closet. Please check your connection and try again."
            print("Error fetching clothing: \(error)")
        }

        isLoading = false
    }
}
