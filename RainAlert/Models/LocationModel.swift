//
//  File.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/14/26.
//

import Foundation

struct SignificantLocationData: Identifiable {
    let id = UUID()
    var latitude: Double
    var longitude: Double
    var name: String?
}

struct CurrentLocationData {
    var latitude: Double
    var longitude: Double
}

class LocationModel: ObservableObject {
    
    @Published var significantLocations: [SignificantLocationData] = []
    @Published var currentLocation: CurrentLocationData?
}
