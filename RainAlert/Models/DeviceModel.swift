//
//  SettingsModel.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/22/25.
//

import Foundation


class SettingsModel: ObservableObject {
    @Published var minRainIntensity: Double = 0.0
    @Published var precipProbabilityThreshold: Double = 0.0
    @Published var morningForecastTime: String = "8:00 AM"
    
    
}
