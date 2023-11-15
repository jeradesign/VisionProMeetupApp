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
    @State var floor: Entity!
//    @State var backWall: Entity
//    @State var frontWall: Entity
//    @State var leftWall: Entity
//    @State var rightWall: Entity
    
    @State var ball: Entity!
    
    var body: some View {
        RealityView { content in
            setupRoom()
            content.add(floor)
            setupBall()
            content.add(ball)
        }
    }
    
    func setupBall() {
        let sphereResource = MeshResource.generateSphere(radius: 0.05)
        let myMaterial = SimpleMaterial(color: .orange, roughness: 0.5, isMetallic: false)
        let myEntity = ModelEntity(mesh: sphereResource, materials: [myMaterial])
        myEntity.position = [0, 2, -2]
        myEntity.generateCollisionShapes(recursive: false)
        var physicsComponent = PhysicsBodyComponent()
        physicsComponent.isAffectedByGravity = true
        myEntity.components[PhysicsBodyComponent.self] = physicsComponent
        ball = myEntity
    }
    
    
    func setupRoom() {
        setupFloor()
    }
    
    func setupFloor() {
        let boxMesh = MeshResource.generateBox(width: 100, height: 1, depth: 100)
        let myMaterial = SimpleMaterial(color: .clear, roughness: 1.0, isMetallic: false)
        let myEntity = ModelEntity(mesh: boxMesh, materials: [myMaterial])
        myEntity.position = [0, -0.5, 0]
        myEntity.generateCollisionShapes(recursive: false)
        var physicsComponent = PhysicsBodyComponent()
        physicsComponent.isAffectedByGravity = false
        physicsComponent.mode = .static
        myEntity.components[PhysicsBodyComponent.self] = physicsComponent
        floor = myEntity
    }

}
