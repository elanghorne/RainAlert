//
//  SettingsModel.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/22/25.
//

import Foundation

struct DeviceData: Codable {
    var deviceToken: String = ""
    var currentLatitude: Double = 34.13
    var currentLongitude: Double = -84.52
    var alertsOn = false
}

class DeviceModel: ObservableObject {
    @Published var data: DeviceData = DeviceData()
    let postPath = "/device"

    init() {
        if let deviceData = UserDefaults.standard.data(forKey: "deviceData") {
            do {
                let decoder = JSONDecoder()
                self.data = try decoder.decode(DeviceData.self, from: deviceData)
            } catch {
                print("Decoding error: \(error)")
            }
        }
    }
    
    func save() {
        do {
            let encoder = JSONEncoder()
            let deviceData = try encoder.encode(self.data)
            UserDefaults.standard.set(deviceData, forKey: "deviceData") // may need to change this eventually. alertsOn is probably the only thing that should persist here.
        } catch {
            print("Encoding error: \(error)")
        }
    }
    
    func format() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        return try encoder.encode(self.data)
    }
    
}
