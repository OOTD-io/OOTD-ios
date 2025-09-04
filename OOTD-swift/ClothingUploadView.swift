//
//  ClothingUploadView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/16/25.
//

import SwiftUI
import PhotosUI

struct ClothingUploadView: View {
    @StateObject private var viewModel = ClothingUploadViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var frontImage: UIImage?
    @State private var backImage: UIImage?
    @State private var tagImage: UIImage?

    @State private var showCamera = false
    @State private var activeCameraTarget: String?

    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Text("Upload Clothing Images")
                    .font(.title2)
                    .bold()
                    .padding(.top)

                HStack(spacing: 20) {
                    UploadTile(title: "Front*", image: $frontImage, onSelectPhoto: { pickPhoto(for: "front") }, onTakePhoto: { openCamera(for: "front") })
                    UploadTile(title: "Back", image: $backImage, onSelectPhoto: { pickPhoto(for: "back") }, onTakePhoto: { openCamera(for: "back") })
                    UploadTile(title: "Tag", image: $tagImage, onSelectPhoto: { pickPhoto(for: "tag") }, onTakePhoto: { openCamera(for: "tag") })
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Button(action: {
                    Task {
                        await viewModel.saveClothing(
                            frontImage: frontImage!,
                            backImage: backImage,
                            tagImage: tagImage
                        )
                    }
                }) {
                    Text("Save Clothing")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(frontImage == nil ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(frontImage == nil || viewModel.isUploading)

                Spacer()
            }
            .padding()
            .photosPicker(isPresented: $showingPicker, selection: $selectedPickerItem, matching: .images)
            .sheet(isPresented: $showCamera) {
                CameraPicker { capturedImage in
                    applyImage(capturedImage, to: activeCameraTarget)
                }
            }
            .onChange(of: selectedPickerItem, perform: { _ in loadPickerImage() })
            .onChange(of: viewModel.uploadSuccess) { success in
                if success {
                    // Dismiss after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            }

            if viewModel.isUploading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                ProgressView("Analyzing...")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }

            if viewModel.uploadSuccess {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    Text("Success!")
                        .font(.title)
                        .bold()
                }
                .padding(40)
                .background(Color.white)
                .cornerRadius(10)
            }
        }
    }

    // MARK: Picker & Camera Handling
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
                await MainActor.run {
                    applyImage(uiImage, to: activeCameraTarget)
                }
            }
        }
    }

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
