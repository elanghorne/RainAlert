//
//  File.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/14/26.
//

import Foundation

struct LocationData: Identifiable {
    let id = UUID()
    var latitude: Double
    var longitude: Double
    var name: String?
}

class LocationModel: ObservableObject {
    @Published var significantLocations: [LocationData] = []
    @Published var currentLocation: LocationData?
}
