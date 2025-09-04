//
//  ClothesAdderView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/16/25.
//

import SwiftUI
import PhotosUI

struct ClothesAdderView: View {
    @State private var isShowingPhotoPicker = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [Image] = []
    @State private var selectedImage: UIImage?
    
    
    @State private var showingCamera = false
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack {
                    Text("Add Image of front of Clothing")
                }
                .border(Color.gray)
                Spacer()
                Spacer()
                VStack {
                    Text("Add Image of back of Clothing")
                }
                .border(Color.gray)
                Spacer()
            }
            VStack {
                Text("Add Image of Tag")
            }
            .border(Color.gray)
            Spacer()
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 1,
                matching: .images, // Filter to only show images
                preferredItemEncoding: .automatic
            ) {
                Text("Select Photo") // Button or other view that triggers the picker
            }
            .onChange(of: selectedItems) {_, newItems in
                Task {
                    selectedImages = await loadImages(from: newItems)
                }
            }
            
            
            
            Button {
                showingCamera = true
            } label: {
                Text("Take Photo")
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView(image: $selectedImage)
            }
            
            Spacer()
            Spacer()
            Spacer()
        }

    }
    
    func loadImages(from items: [PhotosPickerItem]) async -> [Image] {
        var images: [Image] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    images.append(Image(uiImage: uiImage))
                }
            }
        }
        return images
    }
}

#Preview {
    ClothesAdderView()
}
