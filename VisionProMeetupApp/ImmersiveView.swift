//
//  ImmersiveView.swift
//  VisionProMeetupApp
//
//  Created by John Brewer on 11/14/23.
//

import SwiftUI
import RealityKit
import RealityKitContent

@MainActor
struct ImmersiveView: View {
    @State private var scene: Entity!
    
    var body: some View {
        RealityView { content in
            if let scene = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                self.scene = scene
                content.add(scene)
                content.add(setupInvisibleEntity())
            }
        }
        .task {
            do {
                try await Task.sleep(for: .seconds(3))
                for await _ in GameControllerHandlerSystem.shared!.asyncStream {
                    scene.addChild(setupBall())
                }
            } catch {
                return
            }
        }
    }
    
    func setupInvisibleEntity() -> Entity {
        let myEntity = Entity()
        myEntity.position = [0, 0, 0]
        myEntity.components[GameControllerPawnComponent.self] = GameControllerPawnComponent()
        
        return myEntity
    }
    
    func setupBall() -> Entity {
        let sphereResource = MeshResource.generateSphere(radius: 0.05)
        let myMaterial = SimpleMaterial(color: .orange, roughness: 0.5, isMetallic: false)
        let myEntity = ModelEntity(mesh: sphereResource, materials: [myMaterial])
        myEntity.position = [0, 2, 0]
        myEntity.generateCollisionShapes(recursive: false)
        var physicsComponent = PhysicsBodyComponent()
        physicsComponent.isAffectedByGravity = true
        myEntity.components[PhysicsBodyComponent.self] = physicsComponent
        return myEntity
    }
    
}
