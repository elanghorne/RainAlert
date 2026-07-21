//
//  ScheduleView.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/3/26.
//
import SwiftUI
import Foundation

struct WindowRow: View {
    @Binding var window: Window
//    @ObservedObject var scheduleModel: ScheduleModel
    var index: Int
    
    var body: some View {
        HStack {
            Text("\(index + 1) | ")
            Text("Start")
            DatePicker(
                "Start",
                selection: $window.startTime,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            
            Text("End")
            DatePicker(
                "End",
                selection: $window.endTime,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            
        }
    }
}

struct ScheduleView: View {
//    @State var windows: [Window] = []
    @State var windowsConfirmed: Bool = false
    @ObservedObject var scheduleModel: ScheduleModel

    
    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            VStack {
                Text("Customize Notification Schedule")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(.black)
                
                
                List {
                    ForEach($scheduleModel.windows) { $window in
                        WindowRow(window: $window, index: scheduleModel.windows.firstIndex(where: { element in element.id == window.id})!)
                    }
                    .onDelete { indexSet in scheduleModel.windows.remove(atOffsets: indexSet) }
                }
                .scrollContentBackground(.hidden)
                .background(AppColor.background)
                
                if(scheduleModel.windows.count < 5){
                    Button(action: {
                        // append Window to windows
                        scheduleModel.windows.append(Window())
                    }) {
                        // label for button
                        HStack {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                            Text("Add Window")
                                .font(.system(size: 25, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(AppColor.primary))
                        .shadow(color: AppColor.primary.opacity(0.6), radius: 20)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    scheduleModel.save()
                    do {
                        let jsonData = try scheduleModel.format()
                        Task {
                            do {
                                let publisher = DataPublisher() // will actually be passing a shared publisher instance to each view
                                try await publisher.post(jsonData, to: scheduleModel.postPath)
                            } catch {
                                print("POST Error: \(error)")
                            }
                        }

                    } catch {
                        print("Formatting error: \(error)")
                    }
                    windowsConfirmed = true
                    // trying to flash the button green with a check before returning to HomeView upon confirmation
                }) {
                    if(!windowsConfirmed){
                        HStack {

                            Text("Confirm")
                                .font(.system(size: 25, weight: .semibold))
                                .foregroundColor(.white)
                            
                        }
                        .padding()
                    } else {
                        HStack {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        
                        }
                        .padding()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(windowsConfirmed ? .green : .red)

            }
        }
    }
}

var scheduleDummy = ScheduleModel()
#Preview {
    ScheduleView(scheduleModel: scheduleDummy)
}
