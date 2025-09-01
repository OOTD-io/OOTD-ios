import SwiftUI
import PhotosUI

struct ClothingUploadView: View {
    @StateObject private var viewModel = ClothingUploadViewModel()

    @State private var frontImage: UIImage?
    @State private var backImage: UIImage?
    @State private var tagImage: UIImage?

    @State private var showCamera = false
    @State private var activeCameraTarget: String?

    var body: some View {
        VStack(spacing: 30) {
            Text("Upload Clothing Images")
                .font(.title2)
                .bold()
                .padding(.top)

            HStack(spacing: 20) {
                UploadTile(title: "Front", image: $frontImage, onSelectPhoto: { pickPhoto(for: "front") }, onTakePhoto: { openCamera(for: "front") })
                UploadTile(title: "Back", image: $backImage, onSelectPhoto: { pickPhoto(for: "back") }, onTakePhoto: { openCamera(for: "back") })
                UploadTile(title: "Tag", image: $tagImage, onSelectPhoto: { pickPhoto(for: "tag") }, onTakePhoto: { openCamera(for: "tag") })
            }

            if viewModel.isLoading {
                ProgressView("Uploading...")
                    .padding()
            } else {
                Button(action: upload) {
                    Text("Analyze and Save Clothing")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(frontImage == nil ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(frontImage == nil)
                .padding()
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            if viewModel.isSuccess {
                Text("Upload successful! The AI is analyzing your item.")
                    .foregroundColor(.green)
                    .padding()
                    .onAppear {
                        // Reset after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            resetForm()
                        }
                    }
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
        .onChange(of: selectedPickerItem, perform: loadPickerImage)
    }

    // MARK: - Actions
    private func upload() {
        viewModel.uploadClothing(frontImage: frontImage, backImage: backImage, tagImage: tagImage)
    }

    private func resetForm() {
        frontImage = nil
        backImage = nil
        tagImage = nil
        viewModel.isSuccess = false
        viewModel.errorMessage = nil
    }

    // MARK: - Picker Handling
    @State private var showingPicker = false
    @State private var selectedPickerItem: PhotosPickerItem?

    private func pickPhoto(for type: String) {
        activeCameraTarget = type
        showingPicker = true
    }

    private func loadPickerImage(oldValue: PhotosPickerItem?, newValue: PhotosPickerItem?) {
        guard let item = newValue else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    applyImage(uiImage, to: activeCameraTarget)
                }
            }
        }
    }

    // MARK: - Camera Handling
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
