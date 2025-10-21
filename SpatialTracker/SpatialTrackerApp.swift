//
//  SpatialTrackerApp.swift
//  SpatialTracker
//
//  Created by John Brewer on 10/4/25.
//

import SwiftUI

@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
}

@main
struct SpatialTrackerApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
