//
//  LocationView.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/3/26.
//

import SwiftUI
import MapKit

//struct Location: Identifiable {
//    let id = UUID()
//    var name: String?
//    var latitude: Double
//    var longitude: Double
//    
//}

struct LocationRow: View {
    @Binding var location: SignificantLocationData
    var index: Int
    var body: some View {
        HStack {
            Text(location.name ?? "Location \(index + 1)")
        }
    }
}

struct LocationView: View {
    @State var locationsConfirmed: Bool = false
    @State var presentAddLocationSheet = false
    @ObservedObject var locationModel: SignificantLocationModel
    
    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            VStack {
                Text("Significant Locations")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(.black)
                
                List {
                    ForEach($locationModel.significantLocations) { $location in
                        LocationRow(location: $location, index: locationModel.significantLocations.firstIndex(where: { element in element.id == location.id})!)
                    }
                    .onDelete { indexSet in locationModel.significantLocations.remove(atOffsets: indexSet) }
                }
                .scrollContentBackground(.hidden)
                .background(AppColor.background)
                
                if(locationModel.significantLocations.count < 3){
//                    Button(action: {
//                        // bring up sheet to search for an address
//                        presentAddLocationSheet = true
//                        
//                    }) {
                    NavigationLink {
                        SearchLocationView(locationModel: locationModel)
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                            Text("Add Location")
                                .font(.system(size: 30, weight: .semibold))
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
                /* ultimately this button should not appear unless changes are made.
                 then user can confirm and the checkmark appears.
                 this then triggers the sending of data to the backend.
                 */
                Button(action: {
                    locationModel.save()
                    locationModel.postToBackend()
                    locationsConfirmed = true
                }) {
                    if(!locationsConfirmed){
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
                .tint(locationsConfirmed ? .green : .red)
            }
        }
    }
}


#Preview {
    var locationModel = SignificantLocationModel()
    LocationView(locationModel: locationModel)
}
