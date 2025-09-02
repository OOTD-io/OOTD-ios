import SwiftUI

struct ClothingListView: View {
    let title: String
    let items: [ClothingItem]

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items) { item in
                    NavigationLink(destination: ClothingDetailView(clothing: item)) {
                        if let imageUrl = item.images?.front, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.1).overlay(ProgressView())
                            }
                        } else {
                            Color.gray.opacity(0.1).overlay(Image(systemName: "photo.on.rectangle"))
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .clipped()
                }
            }
            .padding()
        }
        .navigationTitle(title)
    }
}
