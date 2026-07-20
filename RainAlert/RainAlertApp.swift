//
//  RainAlertApp.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/22/25.
//

import SwiftUI

@main
struct RainAlertApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
