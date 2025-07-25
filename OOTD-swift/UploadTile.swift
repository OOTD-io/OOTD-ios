//
//  UploadTile.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/16/25.
//

import SwiftUI
import PhotosUI


struct UploadTile: View {
    let title: String
    @Binding var image: UIImage?
    var onSelectPhoto: () -> Void
    var onTakePhoto: () -> Void

    @State private var showingOptions = false

    var body: some View {
        VStack {
            Button {
                showingOptions = true
            } label: {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                        Text(title)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 100, height: 100)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
                }
            }
            .confirmationDialog("Upload \(title)", isPresented: $showingOptions, titleVisibility: .visible) {
                Button("Take a Photo", action: onTakePhoto)
                Button("Choose from Library", action: onSelectPhoto)
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}
