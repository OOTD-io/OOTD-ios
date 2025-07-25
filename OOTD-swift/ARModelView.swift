//
//  ARModelView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/17/25.
//
import SwiftUI
import RealityKit
import ARKit


struct ARModelView: UIViewRepresentable {
    let modelName: String // name of .usdz file in bundle, no extension

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Optional: configure lighting/environment
//        arView.cameraMode = .nonAR
        arView.environment.sceneUnderstanding.options = []

        // Load model from bundle
        if let modelEntity = try? ModelEntity.loadModel(named: modelName) {
            print("✅ Model loaded successfully")

            let anchorEntity = AnchorEntity(world: [0, 0, -1])
            anchorEntity.addChild(modelEntity)

            // Scale it if needed
            modelEntity.setScale(SIMD3<Float>(0.5, 0.5, 0.5), relativeTo: anchorEntity)
            modelEntity.generateCollisionShapes(recursive: true)
            arView.installGestures(.all, for: modelEntity)

            arView.scene.anchors.append(anchorEntity)
        } else {
            print("❌ Could not load model \(modelName).usdz")
        }

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
