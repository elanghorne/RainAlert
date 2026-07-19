//
//  ForecastModel.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/14/26.
//
import Foundation

struct ForecastData: Codable {
    var forecastTime: Date = Calendar.current.startOfDay(for: Date())
    var includeCurrentLocation: Bool = true
    var includeSignificantLocations: Bool = false
}
class ForecastModel: ObservableObject {
    @Published var data: ForecastData = ForecastData()
    
    init() {
        if let forecastData = UserDefaults.standard.data(forKey: "forecastData") {
            do {
                let decoder = JSONDecoder()
                self.data = try decoder.decode(ForecastData.self, from: forecastData)
            } catch {
                print("Decoding error: \(error)")
            }
        }
    }
    
    func save() {
        do {
            let encoder = JSONEncoder()
            let forecastData = try encoder.encode(self.data)
            UserDefaults.standard.set(forecastData, forKey: "forecastData")
        } catch {
            print("Encoding error: \(error)")
        }

    }
}
