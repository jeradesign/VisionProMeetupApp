//
//  VisionProMeetupAppApp.swift
//  VisionProMeetupApp
//
//  Created by John Brewer on 11/14/23.
//

import SwiftUI

@main
struct VisionProMeetupAppApp: App {
    init() {
        GameControllerHandlerSystem.registerSystem()
        GameControllerPawnComponent.registerComponent()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
