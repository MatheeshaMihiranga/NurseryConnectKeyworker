//
//  NurseryConnectVisionApp.swift
//  NurseryConnectVision
//
//  Part B – visionOS companion for NurseryConnect Keyworker.
//  Presents an immersive spatial dashboard where keyworkers can review
//  assigned children, diary entries, and incident alerts in shared space.
//
//  To add this target in Xcode:
//  1. File > New > Target > visionOS > App
//  2. Name: NurseryConnectVision
//  3. Add shared Models, Services, SampleData, ViewModels to the new target membership
//  4. Add this folder's files to the new target
//

import SwiftUI
import RealityKit

@main
struct NurseryConnectVisionApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        // Main window — spatial dashboard
        WindowGroup(id: "main") {
            SpatialDashboardView()
                .environment(appModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 900, height: 640)

        // Immersive space — full environment with floating child panels
        ImmersiveSpace(id: "immersive") {
            ImmersiveChildPanelsView()
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
