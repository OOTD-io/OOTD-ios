//
//  ClothingDetailView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/16/25.
//

import SwiftUI

struct ClothingDetailView: View {
    let item: ClothingItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: item.images.front)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                    case .failure:
                        Image(systemName: "photo.fill")
                            .font(.largeTitle)
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    default:
                        ProgressView()
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)

                Text(item.subtype.capitalized)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(label: "Type", value: item.type.capitalized)
                    InfoRow(label: "Color", value: item.color.capitalized)
                    InfoRow(label: "Material", value: item.material.capitalized)
                    if let brand = item.brand {
                        InfoRow(label: "Brand", value: brand)
                    }
                    if let size = item.size {
                        InfoRow(label: "Size", value: size)
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(Color.primary)
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}
