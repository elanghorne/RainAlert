//
//  AppConfig.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/20/26.
//


import Foundation

enum AppConfig {
    static var backendBaseURL: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "BACKEND_BASE_URL") as? String else {
            fatalError("BACKEND_BASE_URL missing from Info.plist — check Config.xcconfig is set up")
        }
        return url
    }
}
