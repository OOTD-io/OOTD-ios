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
            VStack(spacing: 20) {
                //            if let filename = item.usdzFilename,
                //            Bundle.main.url(forResource: <#T##String?#>, withExtension: <#T##String?#>)
                //            let url = Bundle.main.url(forResource: "harry_potter_uniform", withExtension: "usdz")
                //            USDZPreview(usdzURL: url!)
                //                    .frame(height: 300)
                //                    .cornerRadius(12)
                //                    .padding(.top)
                //            ARModelView(modelName: "harry_potter_uniform")
                if let sceneName = item.sceneImage {
                    SceneKitView(modelName: sceneName)
//                        .ignoresSafeArea()
                                    .frame(height: 300)
                    //                .cornerRadius(12)
                    //                .padding()
                    //                .background(.clear)
                } else {
                    item.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
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
}
