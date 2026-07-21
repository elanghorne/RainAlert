//
//  ScheduleModel.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/14/26.
//
import Foundation

struct Window: Identifiable, Codable{
    var id = UUID()
    var startTime = Calendar.current.startOfDay(for: Date())
    var endTime = Calendar.current.startOfDay(for: Date())
}

struct SchedulePackage: Codable {
    var deviceToken: String = ""
    var data: [Window] = []
}

class ScheduleModel: ObservableObject {
    @Published var windows: [Window] = []
    let postPath = "/schedule"
    
    init() {
        if let windowData = UserDefaults.standard.data(forKey: "scheduleWindows") {
            do {
                let decoder = JSONDecoder()
                self.windows = try decoder.decode([Window].self, from: windowData)
            } catch {
                print("Decoding error: \(error)")
            }
        }
    }
    
    func save() {
        do {
            let encoder = JSONEncoder()
            let windowData = try encoder.encode(self.windows)
            UserDefaults.standard.set(windowData, forKey: "scheduleWindows")
        } catch {
            print("Encoding error: \(error)")
        }
    }
    
    func format(withToken token: String) throws -> Data {
        let package = SchedulePackage(deviceToken: token, data: self.windows)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        return try encoder.encode(package)
    }
    
}
