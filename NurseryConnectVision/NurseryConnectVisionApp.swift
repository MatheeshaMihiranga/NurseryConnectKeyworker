//
//  NurseryConnectVisionApp.swift
//  NurseryConnectVision
//
//  Part B – visionOS companion for NurseryConnect Keyworker.
//  Presents a spatial dashboard (WindowGroup) and an immersive space
//  with floating RealityKit child panels (ImmersiveSpace).
//

import SwiftUI
import RealityKit

@main
struct NurseryConnectVisionApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        // Main glass dashboard window
        WindowGroup(id: "main") {
            SpatialDashboardView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 900, height: 640)

        // Immersive space – floating 3D child panels
        ImmersiveSpace(id: "immersive") {
            ImmersiveChildPanelsView()
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
