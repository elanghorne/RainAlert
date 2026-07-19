//
//  ScheduleModel.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/14/26.
//
import Foundation

struct Window: Identifiable {
    let id = UUID()
    var startTime = Calendar.current.startOfDay(for: Date())
    var endTime = Calendar.current.startOfDay(for: Date())
}

class ScheduleModel: ObservableObject {
    @Published var windows: [Window] = []
}
