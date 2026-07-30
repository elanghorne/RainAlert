//
//  RainAlertApp.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/22/25.
//

import SwiftUI

@main
struct RainAlertApp: App {
    @StateObject private var deviceModel = DeviceModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            HomeView(deviceModel: deviceModel)
                .onAppear {
                    appDelegate.deviceModel = deviceModel
                    print(AppConfig.backendBaseURL)
                }
        }
    }
}
