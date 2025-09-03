import SwiftUI
import PhotosUI

struct ClothingUploadView: View {
    @StateObject private var viewModel = ClothingUploadViewModel()

    @State private var frontImage: UIImage?
    @State private var backImage: UIImage?
    @State private var tagImage: UIImage?

    @State private var showCamera = false
    @State private var activeCameraTarget: String?

    // For the photo picker
    @State private var selectedPickerItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 20) {
            Text("Upload New Clothing")
                .font(.title.bold())
                .padding(.top)

            HStack(spacing: 16) {
                UploadTile(title: "Front", image: $frontImage, onSelectPhoto: { pickPhoto(for: "front") }, onTakePhoto: { openCamera(for: "front") })
                UploadTile(title: "Back", image: $backImage, onSelectPhoto: { pickPhoto(for: "back") }, onTakePhoto: { openCamera(for: "back") })
                UploadTile(title: "Tag", image: $tagImage, onSelectPhoto: { pickPhoto(for: "tag") }, onTakePhoto: { openCamera(for: "tag") })
            }

            if viewModel.isLoading {
                ProgressView("Uploading and analyzing...")
                    .padding()
            }

            if viewModel.isSuccess {
                Text("Upload successful! The AI is analyzing your item.")
                    .foregroundColor(.green)
                    .padding()
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()

            Button(action: upload) {
                Text("Analyze and Save")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(frontImage == nil ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(frontImage == nil || viewModel.isLoading)
        }
        .padding()
        .photosPicker(isPresented: $showingPicker, selection: $selectedPickerItem, matching: .images)
        .sheet(isPresented: $showCamera) {
            CameraPicker { capturedImage in
                applyImage(capturedImage, to: activeCameraTarget)
            }
        }
        .onChange(of: selectedPickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        applyImage(uiImage, to: activeCameraTarget)
                    }
                }
            }
        }
    }

    private func upload() {
        viewModel.uploadClothing(frontImage: frontImage, backImage: backImage, tagImage: tagImage)
    }

    private func pickPhoto(for type: String) {
        activeCameraTarget = type
        showingPicker = true
    }

    private func openCamera(for type: String) {
        activeCameraTarget = type
        showCamera = true
    }

    private func applyImage(_ image: UIImage?, to target: String?) {
        guard let image else { return }
        switch target {
        case "front": frontImage = image
        case "back": backImage = image
        case "tag": tagImage = image
        default: break
        }
    }
}
