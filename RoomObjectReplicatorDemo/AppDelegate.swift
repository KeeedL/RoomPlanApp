//
//  AppDelegate.swift
//  RoomObjectReplicatorDemo
//
//  Created by Jack Mousseau on 6/7/22.
//

import UIKit
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        RoomObjectComponent.registerComponent()
        RoomObjectSystem.registerSystem()
        return true
    }
/*
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        RoomObjectComponent.registerComponent()
        RoomObjectSystem.registerSystem()
        return true
    }*/

    /*
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        RoomObjectComponent.registerComponent()
        RoomObjectSystem.registerSystem()
        
        let contentView = ModelContentView()

        // Use a UIHostingController as window root view controller.
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()
        
        return true
    }
     */
     

}
