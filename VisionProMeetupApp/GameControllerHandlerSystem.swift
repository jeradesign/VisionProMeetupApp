//
//  GameControllerHandlerSystem.swift
//  Lander
//
//  Created by John Brewer on 9/23/23.
//

import RealityKit
import GameKit

private let angleMultiplier:Float = -Float.pi / 4

class GameControllerHandlerSystem: RealityKit.System {
    static var locked = true;
    static var shared: GameControllerHandlerSystem?
    
    var controller: GCController?
#if !os(visionOS)
    var virtualController: GCVirtualController? // must keep reference to virtual controller!
#endif
    var thrustSound: AudioResource?
    var thrustSoundPlaying = false
    var soundController: AudioPlaybackController?
    let asyncStream: AsyncStream<Void>
    let buttonTappedMessage: AsyncStream<Void>.Continuation
        
    private static let query = EntityQuery(where: .has(GameControllerPawnComponent.self))
    
    required init(scene: Scene) {
        (asyncStream, buttonTappedMessage) = AsyncStream.makeStream(of: Void.self, bufferingPolicy: .bufferingNewest(0))
        GameControllerHandlerSystem.shared = self
        setupController()
    }
    
    func update(context: SceneUpdateContext) {
#if os(visionOS)
        context.entities(matching: Self.query, updatingSystemWhen: .rendering).forEach {
            entity in
            handleEntity(entity: entity)
        }
#else
        context.scene.performQuery(Self.query).forEach {
            entity in
            handleEntity(entity: entity)
        }
#endif
    }
    
    func handleEntity(entity: Entity) {
        if let aButton = controller?.extendedGamepad?.buttonA, aButton.isPressed {
            buttonTappedMessage.yield()
            return
        }
    }
    
    func setupController() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.handleControllerDidConnect),
            name: NSNotification.Name.GCControllerDidBecomeCurrent, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.handleControllerDidDisconnect),
            name: NSNotification.Name.GCControllerDidStopBeingCurrent, object: nil)

#if os(iOS)
        setupVirtualController()
        if GCController.controllers().isEmpty {
            virtualController?.connect()
        }
#endif

        if let controller = GCController.controllers().first {
            self.controller = controller
        }
    }
    
    @objc
    func handleControllerDidConnect(_ notification: Notification) {
        guard let gameController = notification.object as? GCController else {
            return
        }
#if os(iOS)
        if gameController != virtualController?.controller {
            virtualController?.disconnect()
        }
#endif
        self.controller = gameController
    }
    
    @objc
    func handleControllerDidDisconnect(_ notification: Notification) {
#if os(iOS)
        if GCController.controllers().isEmpty {
            virtualController?.connect()
        }
#endif
    }

#if os(iOS)
    func setupVirtualController() {
        let config = GCVirtualController.Configuration()
        config.elements = [GCInputLeftThumbstick, GCInputRightThumbstick, GCInputButtonA]
        virtualController = GCVirtualController(configuration: config)
    }
#endif

    @MainActor
    func setupThrustSound() async {
        do {
            if let path = Bundle.main.path(forResource:"large-rocket-engine-86240", ofType: "mp3") {
                let url = URL(fileURLWithPath: path)
#if os(visionOS)
                let config = AudioFileResource.Configuration(shouldLoop: true)
                let thrustSound = try await AudioFileResource(contentsOf: url, configuration: config)
#else
                let thrustSound = try AudioFileResource.load(named: "large-rocket-engine-86240.mp3", inputMode: .spatial, shouldLoop: true)
#endif
                self.thrustSound = thrustSound
            }
        } catch {
            fatalError(error.localizedDescription.debugDescription)
        }
    }
    
}
