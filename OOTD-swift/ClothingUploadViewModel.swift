//
//  ClothingUploadViewModel.swift
//  OOTD-swift
//
//  Created by Jules on 9/3/25.
//

import SwiftUI
import Supabase

@MainActor
class ClothingUploadViewModel: ObservableObject {
    @Published var isUploading = false
    @Published var uploadSuccess = false
    @Published var errorMessage: String?

    func saveClothing(frontImage: UIImage, backImage: UIImage?, tagImage: UIImage?) async {
        isUploading = true
        uploadSuccess = false
        errorMessage = nil

        // 1. Convert images to base64
        guard let frontImageData = frontImage.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Could not process front image."
            isUploading = false
            return
        }
        let frontImageBase64 = frontImageData.base64EncodedString()

        let backImageBase64 = backImage?.jpegData(compressionQuality: 0.8)?.base64EncodedString()
        let tagImageBase64 = tagImage?.jpegData(compressionQuality: 0.8)?.base64EncodedString()

        // 2. Create request body
        let requestBody = SaveClothingRequest(
            front_image: frontImageBase64,
            back_image: backImageBase64,
            tag_image: tagImageBase64
        )

        do {
            // 3. Get auth token
            let session = try await supabase.auth.session
            let token = session.accessToken

            // 4. Make API call
            let url = URL(string: "https://ootd-ai-engine-785972969271.us-central1.run.app/api/outfits/save-clothing")!
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

            // 5. Handle response
            if httpResponse.statusCode == 201 {
                uploadSuccess = true
            } else {
                let errorBody = String(data: data, encoding: .utf8) ?? "No error message"
                errorMessage = "Failed to save clothing: \(errorBody)"
                print("Error saving clothing: \(httpResponse.statusCode) - \(errorBody)")
            }

        } catch {
            errorMessage = error.localizedDescription
            print("Error saving clothing: \(error)")
        }

        isUploading = false
    }
}
