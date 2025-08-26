//
//  ClothingUploadView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/16/25.
//

import SwiftUI
import PhotosUI

struct ClothingUploadView: View {
    @State private var frontImage: UIImage?
    @State private var backImage: UIImage?
    @State private var tagImage: UIImage?

    @State private var frontItem: PhotosPickerItem?
    @State private var backItem: PhotosPickerItem?
    @State private var tagItem: PhotosPickerItem?

    @State private var showCamera = false
    @State private var activeCameraTarget: String?
    @State private var isUploading = false
    @State private var uploadMessage = ""

    var body: some View {
        VStack(spacing: 30) {
            Text("Upload Clothing Images")
                .font(.title2)
                .bold()
                .padding(.top)

            HStack(spacing: 20) {
                UploadTile(title: "Front", image: $frontImage, onSelectPhoto: {
                    pickPhoto(for: "front")
                }, onTakePhoto: {
                    openCamera(for: "front")
                })

                UploadTile(title: "Back", image: $backImage, onSelectPhoto: {
                    pickPhoto(for: "back")
                }, onTakePhoto: {
                    openCamera(for: "back")
                })

                UploadTile(title: "Tag", image: $tagImage, onSelectPhoto: {
                    pickPhoto(for: "tag")
                }, onTakePhoto: {
                    openCamera(for: "tag")
                })
            }

            if isUploading {
                ProgressView()
                    .padding()
            } else {
                Button(action: uploadImages) {
                    Text("Analyze Images")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }

            Text(uploadMessage)
                .font(.caption)
                .foregroundColor(.gray)

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
    }

    func uploadImages() {
        isUploading = true
        uploadMessage = ""

        let imagesToUpload = [frontImage, backImage, tagImage].compactMap { $0 }

        guard !imagesToUpload.isEmpty else {
            uploadMessage = "Please select at least one image."
            isUploading = false
            return
        }

        Task {
            do {
                let response = try await AIEngineClient.shared.describeClothing(images: imagesToUpload)
                DispatchQueue.main.async {
                    self.uploadMessage = response.message
                    self.isUploading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.uploadMessage = "Failed to analyze images. Please try again."
                    print("Error uploading images: \(error)")
                    self.isUploading = false
                }
            }
        }
    }

    // MARK: Picker Handling
    @State private var showingPicker = false
    @State private var selectedPickerItem: PhotosPickerItem?

    func pickPhoto(for type: String) {
        activeCameraTarget = type
        showingPicker = true
    }

    func loadPickerImage() {
        guard let item = selectedPickerItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                applyImage(uiImage, to: activeCameraTarget)
            }
        }
    }

    // MARK: Camera Handling
    func openCamera(for type: String) {
        activeCameraTarget = type
        showCamera = true
    }

    func applyImage(_ image: UIImage?, to target: String?) {
        guard let image else { return }
        switch target {
        case "front": frontImage = image
        case "back": backImage = image
        case "tag": tagImage = image
        default: break
        }
    }
}
