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
    @State private var isSaving = false
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

            if isSaving {
                ProgressView()
                    .padding()
            } else {
                Button(action: saveClothingItem) {
                    Text("Save Clothing")
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

    func saveClothingItem() {
        isSaving = true
        uploadMessage = ""

        guard let front = frontImage else {
            uploadMessage = "The front image is required."
            isSaving = false
            return
        }

        Task {
            do {
                let response = try await AIEngineClient.shared.saveClothing(
                    frontImage: front,
                    backImage: backImage,
                    tagImage: tagImage
                )
                DispatchQueue.main.async {
                    self.uploadMessage = "\(response.message) (ID: \(response.itemId))"
                    self.isSaving = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.uploadMessage = "Failed to save clothing. Please try again."
                    print("Error saving clothing: \(error)")
                    self.isSaving = false
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
