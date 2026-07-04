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

    }
}

struct HomeView: View {
    @State private var alertsOn = false
    @StateObject private var settingsModel = SettingsModel()

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
                    Toggle(isOn: $alertsOn) {
                        Text(alertsOn ? "Notifications On" : "Notifications Off")
                            .foregroundColor(.black)
                    }
                    Spacer()
                    NavigationLink {
                        ScheduleView()
                    } label: {
                        CardView(title: "Notification Schedule", icon: "calendar", color: alertsOn)
                    }
                    
                    Spacer()
                    NavigationLink {
                        ForecastView()
                    } label: {
                        CardView(title: "Daily Forecast", icon: "cloud.sun.rain.fill", color: alertsOn)
                    }
                    
                    Spacer()
                    NavigationLink {
                        LocationView()
                    } label: {
                        CardView(title: "Significant Locations", icon: "mappin.and.ellipse", color: alertsOn)
                    }
                    
                    Spacer()
                    
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    HomeView()
}
