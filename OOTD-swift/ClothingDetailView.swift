//
//  ClothingDetailView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/16/25.
//

import SwiftUICore
import SwiftUI
import SceneKit
import RealityKit

struct ClothingDetailView: View {
    let item: ClothingItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                image(from: item.images["front"])
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 300)
                    .cornerRadius(16)
                    .frame(maxWidth: .infinity)

                Text("\(item.brand ?? "Unknown Brand")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("\(item.type) - \(item.subtype)")
                    .font(.title)
                    .bold()

                VStack(alignment: .leading, spacing: 8) {
                    detailRow(title: "Size", value: item.size)
                    detailRow(title: "Material", value: item.material)
                    detailRow(title: "Primary Color", value: item.color["primary"])
                    detailRow(title: "Secondary Color", value: item.color["secondary"])
                    detailRow(title: "Pattern", value: item.pattern)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Occasions")
                        .font(.headline)
                    Text(item.occasion?.joined(separator: ", ") ?? "N/A")
                        .font(.body)
                }
                .padding()
                
                Spacer()
            }
        }
        .padding()
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // Handle dismiss (via pop)
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(Color.primary) // Or your custom color
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
//                    .background(
//                        RoundedRectangle(cornerRadius: 10)
//                            .fill(Color(UIColor.systemGray5))
//                    )
                }
            }
        }
    }

    private func image(from base64String: String?) -> Image {
        guard let base64String = base64String,
              let data = Data(base64Encoded: base64String),
              let uiImage = UIImage(data: data) else {
            return Image(systemName: "photo")
        }
        return Image(uiImage: uiImage)
    }

    @ViewBuilder
    private func detailRow(title: String, value: String?) -> some View {
        if let value = value, !value.isEmpty {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text(value)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        } else {
            EmptyView()
        }
    }
}
