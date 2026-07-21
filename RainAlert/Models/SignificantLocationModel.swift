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

struct LocationPackage: Codable {
    var deviceToken: String = ""
    var data: [SignificantLocationData] = []
}

class SignificantLocationModel: ObservableObject {
    @Published var significantLocations: [SignificantLocationData] = []
    let postPath = "/location"

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
    
    func format(withToken token: String) throws -> Data {
        let package = LocationPackage(deviceToken: token, data: self.significantLocations)
        let encoder = JSONEncoder()
        
        return try encoder.encode(package)
    }
    
}
