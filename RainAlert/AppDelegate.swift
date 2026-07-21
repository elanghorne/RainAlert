//
//  AppDelegate 2.swift
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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                // permission given. register for remote notifications to get the token
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }

        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // convert token from raw bytes to hex string
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print(tokenString)
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration failed: \(error)")
    }
}
