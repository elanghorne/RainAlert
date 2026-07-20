//
//  AppDelegate.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/20/26.
//


import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // This is the "app launched" hook.
        // Request notification permission here, then register.
        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Apple hands you the token here (as Data). Convert to hex string.
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Registration failed — handle/log.
    }
}