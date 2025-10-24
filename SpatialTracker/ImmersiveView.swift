//
//  ImmersiveView.swift
//  SpatialTracker
//
//  Created by John Brewer on 10/4/25.
//

import SwiftUI
import RealityKit
import GLTFKit2
import GameController

struct ImmersiveView: View {
    var root: Entity = Entity()
    @State var trackingEntity: Entity!

    var body: some View {
        RealityView { content in
            content.add(root)

            // Add the initial RealityKit content
            let urlResource = URLResource(name: "Gnomon.glb")
            if let url = URL(resource: urlResource),
               let trackingEntity = try? await GLTFRealityKitLoader.load(from: url) {
                self.trackingEntity = trackingEntity

                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }
        }
        update: { content in
        }
        .task {
            let configuration = SpatialTrackingSession.Configuration(tracking: [.accessory])
            let session = SpatialTrackingSession()
            await session.run(configuration)
        }
        .task {
            await handleGameControllerSetup()
        }
    }

    // Handle connections with GCControllers and GCStyluses.
    func handleGameControllerSetup() async {
        let controllers = GCController.controllers()
        let styluses = GCStylus.styli

        // Iterate over all the currently connected connections with controllers and styluses.
        for controller in controllers {
            // Controllers which do not support spatial accessory tracking should not attempt to start spatial tracking.
            if controller.productCategory != GCProductCategorySpatialController {
                continue
            }

            try? await setupSpatialAccessory(device: controller)
        }

        for stylus in styluses {
            // Styluses which do not support spatial accessory tracking should not attempt to start spatial tracking.
            if stylus.productCategory != GCProductCategorySpatialStylus {
                continue
            }
            try? await setupSpatialAccessory(device: stylus)
        }

        // Listen to notifications for connections of both controllers and styluses.
        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidConnect, object: nil, queue: nil) {
            notification in
            if let controller = notification.object as? GCController,
               controller.productCategory == GCProductCategorySpatialController {
                Task { @MainActor in
                    try? await self.setupSpatialAccessory(device: controller)
                }
            }
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCStylusDidConnect, object: nil, queue: nil) {
            notification in
            if let stylus = notification.object as? GCStylus,
               stylus.productCategory == GCProductCategorySpatialStylus {
                Task { @MainActor in
                    try? await self.setupSpatialAccessory(device: stylus)
                }
            }
        }
    }


    // Anchor via AnchorEntity to a GCDevice.
    // Set up stylus or controller inputs.
    @MainActor
    func setupSpatialAccessory(device: GCDevice) async throws {
        let source = try await AnchoringComponent.AccessoryAnchoringSource(device: device)

        guard let location = source.locationName(named: "aim") ?? source.locationName(named: "tip") else {
            return
        }

        let anchorEntity = AnchorEntity(.accessory(from: source, location: location),
                                           trackingMode: .predicted,
                                           physicsSimulation: .none)

        anchorEntity.name = "Anchor Entity"
        anchorEntity.addChild(trackingEntity)
        root.addChild(anchorEntity)
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
