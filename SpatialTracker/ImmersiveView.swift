//
//  ImmersiveView.swift
//  SpatialTracker
//
//  Created by John Brewer on 10/4/25.
//

import SwiftUI
import RealityKit
import GLTFKit2

struct ImmersiveView: View {

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            let urlResource = URLResource(name: "ShinySphere.glb")
            if let url = URL(resource: urlResource),
               let ball = try? await GLTFRealityKitLoader.load(from: url) {
                let leftBall = ball
                let rightBall = ball.clone(recursive: true)
                leftBall.position = SIMD3<Float>(-0.5, 1.5, -1.5)
                content.add(leftBall)
                rightBall.position = SIMD3<Float>(0.5, 1.5, -1.5)
                content.add(rightBall)

                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
