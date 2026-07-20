//
//  ForecastView.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/3/26.
//

import SwiftUI

struct ForecastView: View {
    @State var settingsConfirmed = false
//    @State var forecastTime = Calendar.current.startOfDay(for: Date())
    @ObservedObject var forecastModel: ForecastModel
    
    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            VStack {
                
                Text("Customize Daily Forecast")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
                Spacer()
                Spacer()
                HStack {
                    Text("Forecast Time")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundColor(.black)
                    
                    DatePicker(
                        "Time",
                        selection: $forecastModel.data.forecastTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
                Toggle(isOn: $forecastModel.data.includeCurrentLocation) {
                    Text("Include Current Location")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                .padding(.horizontal)
                .padding(.horizontal)
                .padding(.horizontal)
                .padding(.horizontal)
                
                Toggle(isOn: $forecastModel.data.includeSignificantLocations) {
                    Text("Include Significant Locations")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                .padding(.horizontal)
                .padding(.horizontal)
                .padding(.horizontal)

                Spacer()
                Spacer()
                
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        forecastModel.save()
                        forecastModel.postToBackend()
                        settingsConfirmed = true
                        // trying to flash the button green with a check before returning to HomeView upon confirmation
                    }) {
                        if(!settingsConfirmed){
                            HStack {
                                
                                Text("Confirm")
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
                    .tint(settingsConfirmed ? .green : .red)
                    
                }
            }
        }
    }
}

var previewModel = ForecastModel()
#Preview {
    ForecastView(forecastModel: previewModel)
}
