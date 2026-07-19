//
//  File.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/14/26.
//

import Foundation

struct SignificantLocationData: Identifiable, Codable {
    var id = UUID()
    var latitude: Double
    var longitude: Double
    var name: String?
}

struct CurrentLocationData: Codable{
    var currentLatitude: Double
    var currentLongitude: Double
}

class LocationModel: ObservableObject {
    
    @Published var significantLocations: [SignificantLocationData] = []
    @Published var currentLocation: CurrentLocationData? // may move this elsewhere and change this class to SignificantLocationModel
    
    init() {
        if let significantLocationData = UserDefaults.standard.data(forKey: "significantLocationData") {
            do {
                let decoder = JSONDecoder()
                self.significantLocations = try decoder.decode([SignificantLocationData].self, from: significantLocationData)
            } catch {
                print("Decoding error: \(error)")
            }
        }
    }
    
    func save() {
        do {
            let encoder = JSONEncoder()
            let significantLocationData = try encoder.encode(self.significantLocations)
            
            UserDefaults.standard.set(significantLocationData, forKey: "significantLocationData")
        } catch {
            print("Encoding error: \(error)")
        }
    }
}
