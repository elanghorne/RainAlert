//
//  HomeView.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/22/25.
//

import SwiftUI

struct HomeView: View {
    @State private var isPressed = false
    @State private var alertsOn = false
    @StateObject private var settingsModel = SettingsModel()

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea() // extends full screen

            VStack {
                Spacer()
                Spacer()

                Text("RainAlert")
                    .font(.system(size: 25, weight: .semibold))
                    .tracking(1.2)
                    .foregroundColor(.black)
                    .padding(.bottom, 10)
                Spacer()
                Spacer()
                Button(action: {
                    alertsOn = !alertsOn
                    print("Toggle button pressed")
                }) {
                    if alertsOn {
                        ZStack {
                            LinearGradient(gradient: Gradient(colors: [AppColor.primary, AppColor.primary.opacity(0.7)]),
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                                .frame(width: 250, height: 250)
                                .clipShape(Circle())

                            Image(systemName: "cloud.rain")
                                .font(.system(size: 60, weight: .medium))
                                .foregroundColor(AppColor.background)
                        }
                        .frame(width: 250, height: 250)
                         .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
                         .scaleEffect(isPressed ? 0.95 : 1.0)
                         .animation(.spring(), value: isPressed)
                         .simultaneousGesture(
                             DragGesture(minimumDistance: 0)
                                 .onChanged { _ in isPressed = true }
                                 .onEnded { _ in isPressed = false }
                         )
                    } else {
                        ZStack {
                            LinearGradient(gradient: Gradient(colors: [AppColor.secondary, AppColor.secondary.opacity(0.7)]),
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                                .frame(width: 250, height: 250)
                                .clipShape(Circle())

                            Image(systemName: "cloud.rain")
                                .font(.system(size: 60, weight: .medium))
                                .foregroundColor(AppColor.background)
                        }
                        .frame(width: 250, height: 250)
                         .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
                         .scaleEffect(isPressed ? 0.95 : 1.0)
                         .animation(.spring(), value: isPressed)
                         .simultaneousGesture(
                             DragGesture(minimumDistance: 0)
                                 .onChanged { _ in isPressed = true }
                                 .onEnded { _ in isPressed = false }
                         )
                    }
                }
                alertsOn ? Text("Alerts: On") : Text("Alerts: Off")
                Text("Morning Forecast: \(settingsModel.morningForecastTime)")
                Spacer()
                Spacer()
                Spacer()

                HStack {
                    Button(action: {
                        print("Info button pressed")
                    }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20))
                    }
                    Spacer()
                    Button(action: {
                        print("Schedule button pressed")
                    }) {
                        Text("Schedule Alerts")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(AppColor.primary)
                            .foregroundColor(AppColor.background)
                            .clipShape(Capsule())
                            .shadow(radius: 2)
                    }
                    Spacer()
                    Button(action: {
                        print("Settings button pressed")
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    HomeView()
}
