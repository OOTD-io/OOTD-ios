import SwiftUI
import PhotosUI

struct ClothingUploadView: View {
    @State private var frontImage: UIImage?
    @State private var backImage: UIImage?
    @State private var tagImage: UIImage?

    @State private var showingPicker = false
    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var activeCameraTarget: String?
    @State private var showCamera = false

    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 30) {
            Text("Upload Clothing Images")
                .font(.title2).bold().padding(.top)

            HStack(spacing: 20) {
                UploadTile(title: "Front", image: $frontImage, onSelectPhoto: { pickPhoto(for: "front") }, onTakePhoto: { openCamera(for: "front") })
                UploadTile(title: "Back", image: $backImage, onSelectPhoto: { pickPhoto(for: "back") }, onTakePhoto: { openCamera(for: "back") })
                UploadTile(title: "Tag", image: $tagImage, onSelectPhoto: { pickPhoto(for: "tag") }, onTakePhoto: { openCamera(for: "tag") })
            }

            if isLoading {
                ProgressView("Analyzing your item...")
            } else {
                Button(action: saveClothing) {
                    Text("Save Clothing")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(frontImage == nil)
            }

            Spacer()
        }
        .padding()
        .photosPicker(isPresented: $showingPicker, selection: $selectedPickerItem, matching: .images)
        .sheet(isPresented: $showCamera) {
            CameraPicker { capturedImage in
                applyImage(capturedImage, to: activeCameraTarget)
            }
        }
        .onChange(of: selectedPickerItem) {
            loadPickerImage()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func pickPhoto(for type: String) {
        activeCameraTarget = type
        showingPicker = true
    }

    private func loadPickerImage() {
        guard let item = selectedPickerItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                applyImage(uiImage, to: activeCameraTarget)
            }
        }
    }

    private func openCamera(for type: String) {
        activeCameraTarget = type
        showCamera = true
    }

    private func applyImage(_ image: UIImage?, to target: String?) {
        guard let image = image else { return }
        switch target {
        case "front": frontImage = image
        case "back": backImage = image
        case "tag": tagImage = image
        default: break
        }
    }

    private func saveClothing() {
        guard let frontImage = frontImage else {
            alertTitle = "Missing Image"
            alertMessage = "Please select at least a front image."
            showingAlert = true
            return
        }

        isLoading = true

        Task {
            let request = ClothingItemRequest(
                frontImage: frontImage.jpegData(compressionQuality: 0.8)?.base64EncodedString() ?? "",
                backImage: backImage?.jpegData(compressionQuality: 0.8)?.base64EncodedString(),
                tagImage: tagImage?.jpegData(compressionQuality: 0.8)?.base64EncodedString()
            )

            do {
                let response = try await AIEngineService.shared.saveClothing(item: request)
                alertTitle = "Success"
                alertMessage = response.message
                resetForm()
            } catch {
                alertTitle = "Error"
                alertMessage = "Failed to save clothing item. Please try again."
                print("Error saving clothing: \(error)")
            }

            isLoading = false
            showingAlert = true
        }
    }

    private func resetForm() {
        frontImage = nil
        backImage = nil
        tagImage = nil
        selectedPickerItem = nil
    }
}
