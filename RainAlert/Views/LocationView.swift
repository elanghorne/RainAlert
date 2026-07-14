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
    @Binding var location: LocationData
    var index: Int
    var body: some View {
        HStack {
            Text(location.name ?? "Location \(index + 1)")
        }
    }
}

struct LocationView: View {
    @State var locations: [LocationData] = []
    @State var locationsConfirmed: Bool = false
    @State var presentAddLocationSheet = false
    @State var locationModel: LocationModel
    
    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            VStack {
                Text("Select Significant Locations")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(.black)
                
                List {
                    ForEach($locations) { $location in
                        LocationRow(location: $location, index: locations.firstIndex(where: { element in element.id == location.id})!)
                    }
                    .onDelete { indexSet in locations.remove(atOffsets: indexSet) }
                }
                .scrollContentBackground(.hidden)
                .background(AppColor.background)
                
                if(locations.count < 3){
//                    Button(action: {
//                        // bring up sheet to search for an address
//                        presentAddLocationSheet = true
//                        
//                    }) {
                    NavigationLink {
                        SearchLocationView()
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
//        .sheet(isPresented: $presentAddLocationSheet) {
//            NavigationStack {
//                AddLocationSheet()
//                    .toolbar {
//                        ToolbarItem(placement: .cancellationAction) {
//                            Button("Cancel") {
//                                presentAddLocationSheet = false
//                            }
//                        }
//                    }
//            }
//        }
    }

}


#Preview {
    var locationModel = LocationModel()
    LocationView(locationModel: locationModel)
}
