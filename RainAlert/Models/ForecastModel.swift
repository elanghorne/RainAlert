//
//  ForecastModel.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/14/26.
//
import Foundation

class ForecastModel: ObservableObject {
    @Published var forecastTime: Date = Calendar.current.startOfDay(for: Date())
    @Published var includeCurrentLocation: Bool = true
    @Published var includeSignificantLocations: Bool = false
}
