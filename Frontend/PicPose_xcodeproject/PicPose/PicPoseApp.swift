//
//  PicPoseApp.swift
//  PicPose
//
//  Created by Jawahar Nathani on 22/04/25.
//

import SwiftUI

@main
struct PicPoseApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomePageView()
        }
    }
}

#Preview {
    HomePageView()
}
