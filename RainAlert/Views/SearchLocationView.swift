//
//  AddLocationSheet.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/9/26.
//

import SwiftUI
import MapKit


struct SearchLocationView: View {
    @StateObject var locationManager: LocationManager = .init()
    // MARK: Navigation Tag to push view to MapView
    @State var navigationTag: String?
    var locationModel: LocationModel
    
    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea() // extends full screen
            VStack {
                
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Find locations here", text: $locationManager.searchText)
                        .foregroundColor(.black)
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.gray)
                }
                .padding(.vertical, 10)
                
                if let places = locationManager.fetchedPlaces,!places.isEmpty {
                    List {
                        ForEach(places, id: \.self) { place in
                            Button {

                                // MARK: Setting Map Region
                                if let coordinate = place.location?.coordinate {
                                    locationManager.mapView.region = .init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                                    locationManager.addDraggablePin(coordinate: coordinate)
                                    locationManager.updatePlacemark(location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
                                    locationManager.pickedLocation = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                }
                                // MARK: Navigating to MapView
                                navigationTag = "MAPVIEW"
                            } label: {
                                HStack(spacing: 15) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(place.name ?? "")
                                            .font(.title3.bold())
                                        Text(place.locality ?? "")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .listRowBackground(AppColor.background)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(AppColor.background)
//                    .listStyle(.plain)
                    
                } else {
                    // MARK: Live Location Button
                    Button {

                        // MARK: Setting Map Region
                        if let coordinate = locationManager.userLocation?.coordinate {
                            locationManager.mapView.region = .init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                            locationManager.addDraggablePin(coordinate: coordinate)
                            locationManager.updatePlacemark(location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
                        }
                        // MARK: Navigating to MapView
                        navigationTag = "MAPVIEW"
                    } label: {
                        Label {
                            Text("Use Current Location")  // doesn't currently get a location
                        } icon: {
                            Image(systemName: "location.north.circle.fill")
                        }
                        .foregroundColor(AppColor.primary)
                        
                    }
                }
            }
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
            .background {
                NavigationLink(tag: "MAPVIEW", selection: $navigationTag) {
                    MapViewSelection(locationModel: locationModel)
                        .environmentObject(locationManager)
                } label: {}
                    .labelsHidden()
            }
        }
        .navigationTitle("Search Location")
        .toolbarColorScheme(.light, for: .navigationBar)
        .font(.system(size: 20, weight: .semibold))
        .navigationBarTitleDisplayMode(.inline)
    }
}

var dummyLocationModel = LocationModel()
#Preview {
    SearchLocationView(locationModel: dummyLocationModel)
}

// MARK: MapView Live Selection
struct MapViewSelection: View {
    @EnvironmentObject var locationManager: LocationManager
    @State var isNameLocationSheetPresented = false
    var locationModel: LocationModel
    
    var body: some View {
        ZStack {
            MapViewHelper()
                .environmentObject(locationManager)
                .ignoresSafeArea()
            
            // MARK: Displaying data
            if let place = locationManager.pickedPlacemark {
                VStack(spacing: 15) {
                    Text("Confirm Location")
                        .font(.title2.bold())
                        .foregroundColor(.black)
                    
                    HStack(spacing: 15) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(place.name ?? "")
                                .font(.title3.bold())
                                .foregroundColor(.black)
                            Text(place.locality ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                    
                    Button {
                        isNameLocationSheetPresented = true
                        var significantLocation = SignificantLocationData(latitude: locationManager.pickedLocation?.coordinate.latitude ?? 39.13, longitude: locationManager.pickedLocation?.coordinate.longitude ?? -84.52)
                        locationModel.significantLocations.append(significantLocation)
                        
                    } label: {
                        Text("Confirm Location")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.green)
                            }
                            .overlay(alignment: .trailing) {
                                Image(systemName: "arrow.right")
                                    .font(.title3.bold())
                                    .padding(.trailing)
                            }
                            .foregroundColor(.white)
                    }
                    .sheet(isPresented: $isNameLocationSheetPresented) {
                        NameLocationSheet(locationModel: locationModel)
                    }

                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white)
                        .ignoresSafeArea()
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .onDisappear {
            locationManager.pickedLocation = nil
            locationManager.pickedPlacemark = nil
            
            locationManager.mapView.removeAnnotations(locationManager.mapView.annotations)
        }
    }
}

//MARK: UIKit MapView
struct MapViewHelper: UIViewRepresentable {
    @EnvironmentObject var locationManager: LocationManager

    func makeUIView(context: Context) -> MKMapView {
        return locationManager.mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
}
