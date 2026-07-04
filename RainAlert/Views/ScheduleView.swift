//
//  ScheduleView.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/3/26.
//

import SwiftUI
//import Foundation

struct Window: Identifiable {
    let id = UUID()
    var startTime: Date?
    var endTime: Date?
    var windowConfirmed = false
}

struct WindowRow: View {
    @Binding var window: Window
    var index: Int
    
    var body: some View {
        HStack {
            Text("Window \(index + 1)")
            
        }
    }
}

struct ScheduleView: View {
    @State var windows: [Window] = []
    
    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            VStack {
                Text("Customize Notification Schedule")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(.black)
            
                List {
                    ForEach($windows) { $window in
                        WindowRow(window: $window, index: windows.firstIndex(where: { element in element.id == window.id})!)
                    }
                }
                .scrollContentBackground(.hidden)
                Button(action: {
                    // append Window to windows
                    windows.append(Window())
                }) {
                    // label for button
                    HStack {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                        Text("Add Window")
                            .foregroundColor(.white)
                        
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(AppColor.primary))
                }
                
            }
        }
    }
}

#Preview {
    ScheduleView()
}
