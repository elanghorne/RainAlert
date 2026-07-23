//
//  HomeView.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/22/25.
//

import SwiftUI

struct CardView: View {
    let title: String
    let icon: String
    let color: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
            Image(systemName: icon)
                .resizable()
                .foregroundColor(.white)
                .frame(width: 75, height: 75)
        }
        .padding()
        .padding()
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(color ? AppColor.primary : AppColor.secondary))
        .shadow(color: (color ? AppColor.primary : AppColor.secondary).opacity(0.6), radius: 20)

    }
}

struct HomeView: View {
//    @State private var alertsOn = false
    @ObservedObject var deviceModel: DeviceModel
    @StateObject private var locationModel = SignificantLocationModel()
    @StateObject private var forecastModel = ForecastModel()
    @StateObject private var scheduleModel = ScheduleModel()
    @StateObject private var locationManager: LocationManager
    
    init(deviceModel: DeviceModel) {
        self.deviceModel = deviceModel
        _locationManager = StateObject(wrappedValue: LocationManager(deviceModel: deviceModel))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background
                    .ignoresSafeArea() // extends full screen

                
                VStack {
                    Text("RainAlert")
                        .font(.system(size: 30, weight: .semibold))
                        .tracking(1.2)
                        .foregroundColor(.black)
                        .padding(.bottom, 10)
                    Spacer()
                    Toggle(isOn: $deviceModel.data.alertsOn) {
                        Text(deviceModel.data.alertsOn ? "Notifications On" : "Notifications Off")
                            .foregroundColor(.black)
                    }
                    .onChange(of: deviceModel.data.alertsOn) { oldValue, newValue in
                        deviceModel.save()
                        Task {
                            do {
                                let jsonData = try deviceModel.format()
                                do {
                                    let publisher = DataPublisher() // will actually be passing a shared publisher instance to each view
                                    try await publisher.post(jsonData, to: deviceModel.postPath)
                                } catch {
                                    print("DeviceModel POST error: \(error)")
                                }
                            } catch {
                                print("DeviceModel formatting error: \(error)")
                            }
                        }
                    }
                    Spacer()
                    NavigationLink {
                        ScheduleView(deviceModel: deviceModel, scheduleModel: scheduleModel)
                    } label: {
                        CardView(title: "Notification Schedule", icon: "calendar", color: deviceModel.data.alertsOn)
                    }
                    
                    Spacer()
                    NavigationLink {
                        ForecastView(deviceModel: deviceModel, forecastModel: forecastModel)
                    } label: {
                        CardView(title: "Daily Forecast", icon: "cloud.sun.rain.fill", color: deviceModel.data.alertsOn)
                    }
                    
                    Spacer()
                    NavigationLink {
                        LocationView(deviceModel: deviceModel, locationModel: locationModel)
                    } label: {
                        CardView(title: "Significant Locations", icon: "mappin.and.ellipse", color: deviceModel.data.alertsOn)
                    }
                    
                    Spacer()
                    
                }
                .padding(.horizontal)
            }
        }
        .environmentObject(locationManager)
    }
}

var dummyDeviceModel = DeviceModel()
#Preview {
    HomeView(deviceModel: dummyDeviceModel)
}
