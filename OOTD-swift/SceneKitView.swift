//
//  SceneKitView.swift
//  OOTD-swift
//
//  Created by Rahqi Sarsour on 6/17/25.
//

import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
    let modelName: String
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        
        let scene = SCNScene(named: modelName)
        
        sceneView.scene = scene
        
        
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        
        
        let cameraNode = SCNNode()
        
        cameraNode.camera = SCNCamera()
        
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 8)
        scene?.rootNode.addChildNode(cameraNode)
        
        return sceneView
        
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        
    }
}

//#Preview {
//    SceneKitView()
//}
