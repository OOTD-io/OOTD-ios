import SwiftUICore
import SwiftUI
import SceneKit
import RealityKit

struct ClothingDetailView: View {
    let item: ClothingItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let sceneName = item.sceneImage {
                    SceneKitView(modelName: sceneName)
                        .frame(height: 300)
                } else {
                    AsyncImage(url: item.imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 200)
                    .cornerRadius(16)
                    .padding(.top)
                }
                
                Text(item.name)
                    .font(.title2)
                    .bold()
                
                Text("Size: \(item.size)")
                    .font(.body)
                
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
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(Color.primary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                }
            }
        }
    }
}
