import Foundation
import SwiftUI

@MainActor
class ClothingUploadViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSuccess = false

    private let aiEngineService = AIEngineService.shared

    func uploadClothing(frontImage: UIImage?, backImage: UIImage?, tagImage: UIImage?) {
        guard let frontImage = frontImage, let frontData = frontImage.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Front image is required."
            return
        }

        let backData = backImage?.jpegData(compressionQuality: 0.8)
        let tagData = tagImage?.jpegData(compressionQuality: 0.8)

        isLoading = true
        errorMessage = nil
        isSuccess = false

        Task {
            do {
                _ = try await aiEngineService.saveClothing(
                    frontImage: frontData,
                    backImage: backData,
                    tagImage: tagData
                )
                self.isSuccess = true
            } catch {
                self.errorMessage = "Upload failed: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }
}
