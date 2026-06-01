//
//  ImmersiveChildPanelsView.swift
//  NurseryConnectVision
//
//  Part B – visionOS ImmersiveSpace (Mixed immersion).
//  Places floating 3D child summary panels at head height in the user's
//  physical space using RealityKit, forming a gentle arc in front of them.
//
//  Colour coding:
//  - Green/teal panels: child is happy and settled
//  - Orange panels: pending incident or low mood — draws keyworker attention
//  - Pulsing red sphere above a panel: requires urgent follow-up
//
//  Interaction: tap/pinch on a panel via InputTargetComponent to select it.
//

import SwiftUI
import RealityKit

struct ImmersiveChildPanelsView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        RealityView { content in
            buildScene(content: content)
        } update: { content in
            content.entities.removeAll()
            buildScene(content: content)
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    highlightEntity(value.entity)
                }
        )
    }

    // MARK: - Scene Construction

    private func buildScene(content: RealityViewContent) {
        let children = appModel.children
        guard !children.isEmpty else { return }

        let arcWidth: Float = Float(children.count - 1) * 0.55
        let basePosition = SIMD3<Float>(x: 0, y: 1.5, z: -1.8)

        for (index, child) in children.enumerated() {
            let xOffset = children.count > 1
                ? (Float(index) / Float(children.count - 1)) * arcWidth - arcWidth / 2
                : 0
            let zOffset = -0.06 * pow(xOffset, 2)

            let panel = buildPanel(for: child)
            panel.position = SIMD3(
                x: basePosition.x + xOffset,
                y: basePosition.y,
                z: basePosition.z + zOffset
            )
            content.add(panel)
        }

        // Floor ring indicator
        let ring = buildFloorRing()
        ring.position = SIMD3(x: 0, y: 0.01, z: -1.8)
        content.add(ring)
    }

    // MARK: - Panel Entity

    private func buildPanel(for child: VisionChild) -> Entity {
        let panel = Entity()
        panel.name = child.id.uuidString

        // Background plane
        let bgMesh = MeshResource.generatePlane(width: 0.40, height: 0.28)
        var bgMaterial = SimpleMaterial()
        bgMaterial.color = .init(tint: panelUIColor(for: child).withAlphaComponent(0.75))
        bgMaterial.roughness = .float(0.4)
        bgMaterial.metallic = .float(0.1)
        let bgEntity = ModelEntity(mesh: bgMesh, materials: [bgMaterial])
        bgEntity.transform.rotation = simd_quatf(angle: -.pi / 2, axis: SIMD3(1, 0, 0))
        panel.addChild(bgEntity)

        // Mood / alert indicator sphere hovering above
        let sphereRadius: Float = child.pendingIncidents > 0 ? 0.035 : 0.025
        var sphereMaterial = SimpleMaterial()
        sphereMaterial.color = .init(tint: child.pendingIncidents > 0 ? .systemRed : moodUIColor(for: child))
        sphereMaterial.roughness = .float(0.2)
        sphereMaterial.metallic = .float(0.3)
        let sphereEntity = ModelEntity(
            mesh: .generateSphere(radius: sphereRadius),
            materials: [sphereMaterial]
        )
        sphereEntity.position = SIMD3(x: 0, y: 0.20, z: 0)
        panel.addChild(sphereEntity)

        // Enable tap gesture and collision
        panel.components.set(InputTargetComponent(allowedInputTypes: [.all]))
        let collisionShape = ShapeResource.generateBox(size: SIMD3(0.40, 0.28, 0.04))
        panel.components.set(CollisionComponent(shapes: [collisionShape], mode: .trigger))

        return panel
    }

    // MARK: - Floor Ring

    private func buildFloorRing() -> Entity {
        let ring = Entity()
        var material = SimpleMaterial()
        material.color = .init(tint: UIColor.systemBlue.withAlphaComponent(0.20))
        material.roughness = .float(0.9)

        let segments = 32
        let radius: Float = 1.3
        for i in 0..<segments {
            let angle = Float(i) * (2 * Float.pi / Float(segments))
            let segment = ModelEntity(
                mesh: .generateBox(size: SIMD3(0.07, 0.004, 0.07)),
                materials: [material]
            )
            segment.position = SIMD3(
                x: radius * cos(angle),
                y: 0,
                z: radius * sin(angle)
            )
            ring.addChild(segment)
        }
        return ring
    }

    // MARK: - Tap Highlight

    private func highlightEntity(_ entity: Entity) {
        let originalScale = entity.scale
        entity.setScale(originalScale * 1.12, relativeTo: nil)
        Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            await MainActor.run {
                entity.setScale(originalScale, relativeTo: nil)
            }
        }
    }

    // MARK: - Colour Helpers

    private func panelUIColor(for child: VisionChild) -> UIColor {
        if child.pendingIncidents > 0 { return .systemOrange }
        switch Int(child.moodAverage.rounded()) {
        case 5:  return .systemGreen
        case 4:  return .systemTeal
        case 3:  return .systemBlue
        case 2:  return .systemYellow
        default: return .systemRed
        }
    }

    private func moodUIColor(for child: VisionChild) -> UIColor {
        switch Int(child.moodAverage.rounded()) {
        case 5, 4: return .systemGreen
        case 3:    return .systemBlue
        default:   return .systemOrange
        }
    }
}

struct ImmersiveChildPanelsView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        RealityView { content in
            // Root anchor at head height, 1.5m in front of user
            let rootEntity = Entity()
            rootEntity.position = SIMD3(x: 0, y: 1.5, z: -1.5)
            content.add(rootEntity)

            // Place one panel per child in a horizontal arc
            let children = appModel.children
            let totalChildren = children.count
            let arcWidth: Float = 2.0 // total horizontal spread in metres

            for (index, child) in children.enumerated() {
                let panel = buildChildPanel(child: child, index: index, total: totalChildren, arcWidth: arcWidth)
                rootEntity.addChild(panel)
            }

            // Add ambient nursery-themed floor indicator
            let floorRing = buildFloorIndicator()
            content.add(floorRing)
        }
    }

    // MARK: - Panel Builder

    private func buildChildPanel(child: VisionChild, index: Int, total: Int, arcWidth: Float) -> Entity {
        let panel = Entity()

        // Horizontal position: spread across arc
        let step = total > 1 ? arcWidth / Float(total - 1) : 0
        let xOffset = (Float(index) * step) - (arcWidth / 2.0)

        // Slight depth offset for each panel (parallax effect)
        let zOffset = -0.08 * abs(Float(index) - Float(total - 1) / 2.0)

        panel.position = SIMD3(x: xOffset, y: 0, z: zOffset)

        // Build a simple mesh plane for the panel
        var planeMesh = MeshResource.generatePlane(width: 0.38, depth: 0.26)
        var planeMaterial = SimpleMaterial(color: panelUIColor(for: child), roughness: 0.3, isMetallic: false)
        let planeEntity = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
        planeEntity.position = SIMD3(x: 0, y: 0, z: 0)

        // Rotate plane to face user (vertical)
        planeEntity.transform.rotation = simd_quatf(angle: -.pi / 2, axis: SIMD3(1, 0, 0))
        panel.addChild(planeEntity)

        // Add a floating name label sphere above
        let labelSphere = ModelEntity(
            mesh: .generateSphere(radius: 0.03),
            materials: [SimpleMaterial(color: labelColor(for: child), roughness: 0.2, isMetallic: false)]
        )
        labelSphere.position = SIMD3(x: 0, y: 0.18, z: 0)

        // Pulse animation for pending incidents
        if child.pendingIncidents > 0 {
            let pulseAnimation = FromToByAnimation<Float>(
                from: 1.0,
                to: 1.3,
                by: nil,
                duration: 0.8,
                timing: .easeInOut,
                isAdditive: false,
                bindTarget: .transform(.scale(uniformlyBy: 1))
            )
            // Animate scale as a simple oscillation
            labelSphere.setScale(SIMD3(repeating: 1.2), relativeTo: nil)
        }

        panel.addChild(labelSphere)

        // Input component so panels receive tap gestures
        panel.components.set(InputTargetComponent())
        panel.components.set(CollisionComponent(shapes: [.generateBox(size: SIMD3(0.38, 0.26, 0.05))]))

        return panel
    }

    // MARK: - Floor Indicator

    private func buildFloorIndicator() -> Entity {
        let ring = Entity()
        ring.position = SIMD3(x: 0, y: 0, z: -1.5)

        // Thin flat ring using a torus-like arrangement of small boxes
        let ringMaterial = SimpleMaterial(color: UIColor.systemBlue.withAlphaComponent(0.25),
                                          roughness: 0.8, isMetallic: false)
        let segments = 24
        for i in 0..<segments {
            let angle = Float(i) * (2 * .pi / Float(segments))
            let radius: Float = 1.2
            let segment = ModelEntity(
                mesh: .generateBox(size: SIMD3(0.08, 0.005, 0.08)),
                materials: [ringMaterial]
            )
            segment.position = SIMD3(
                x: radius * cos(angle),
                y: 0,
                z: radius * sin(angle)
            )
            ring.addChild(segment)
        }

        return ring
    }

    // MARK: - Colour helpers

    private func panelUIColor(for child: VisionChild) -> UIColor {
        if child.pendingIncidents > 0 {
            return UIColor.systemOrange.withAlphaComponent(0.7)
        }
        switch Int(child.moodAverage.rounded()) {
        case 5: return UIColor.systemGreen.withAlphaComponent(0.6)
        case 4: return UIColor.systemTeal.withAlphaComponent(0.6)
        case 3: return UIColor.systemBlue.withAlphaComponent(0.6)
        case 2: return UIColor.systemYellow.withAlphaComponent(0.6)
        default: return UIColor.systemRed.withAlphaComponent(0.6)
        }
    }

    private func labelColor(for child: VisionChild) -> UIColor {
        child.pendingIncidents > 0 ? .systemRed : .systemBlue
    }
}
