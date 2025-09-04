import SwiftUI

struct ClothingDetailView: View {
    let clothing: ClothingItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Display the front image from the URL, handling optionals safely
                AsyncImage(url: URL(string: clothing.images.front)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 300)
                .cornerRadius(12)
                .padding(.top)
                
                // Display clothing details from the new model, handling optionals safely
                VStack(alignment: .leading, spacing: 8) {
                    Text(clothing.type.capitalized)
                        .font(.largeTitle.bold())
                    Text(clothing.subtype ?? "Unknown Subtype")
                        .font(.title2)
                        .foregroundColor(.secondary)

                    HStack {
                        Text("Color:")
                            .fontWeight(.semibold)
                        Text(clothing.color ?? "Unknown Color")
                    }

                    if let brand = clothing.brand {
                        HStack {
                            Text("Brand:")
                                .fontWeight(.semibold)
                            Text(brand)
                        }
                    }

                    if let size = clothing.size {
                        HStack {
                            Text("Size:")
                                .fontWeight(.semibold)
                            Text(size)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
        }
        .padding()
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
