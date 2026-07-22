//
//  CurrentLocationModel.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/19/26.
//
import Foundation

struct CurrentLocationData: Codable{
    var currentLatitude: Double
    var currentLongitude: Double
}
class CurrentLocationModel {
    @Published var currentLocation: CurrentLocationData?
}
