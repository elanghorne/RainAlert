//
//  LocationManager.swift
//  RainAlert
//
//  Created by Eric Langhorne on 7/13/26.
//

import SwiftUI
import CoreLocation
import MapKit
// MARK: Combine Framework to Watch Texfield Change
import Combine

struct CurrentLocationData: Codable{
    var currentLatitude: Double
    var currentLongitude: Double
}

func postToBackend(data: CurrentLocationData) {
    // might add a DeviceModel for this and device_token. this way there's a model for each db table
}

class LocationManager: NSObject, ObservableObject, MKMapViewDelegate, CLLocationManagerDelegate {
    // MARK: Properties
    @Published var mapView: MKMapView = .init()
    @Published var manager: CLLocationManager = .init()
    @Published var currentLocation: CurrentLocationData?
    
    // MARK: Search Bar Text
    @Published var searchText: String = ""
    var cancellable: AnyCancellable?
    @Published var fetchedPlaces: [CLPlacemark]?
    
    // MARK: User Location
    @Published var userLocation: CLLocation?
    
    // MARK: Final Location
    @Published var pickedLocation: CLLocation?
    @Published var pickedPlacemark: CLPlacemark?
    
    override init() {
        super.init()
        // MARK: Setting delegates
        manager.delegate = self
        mapView.delegate = self
        
        // MARK: Requesting location access
        manager.requestAlwaysAuthorization()
        
        // MARK: Search Textfield Watching
        cancellable = $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { value in
                if value != "" {
                    self.fetchPlaces(value: value)

                } else {
                    self.fetchedPlaces = nil
                }

            })
    }
    
    func fetchPlaces(value: String) {
        // MARK: Fetching places using MKLocalSearch and async/await
        Task {
            do {
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = value.lowercased()
                
                let response = try await MKLocalSearch(request: request).start()
                // we can also use mainactor to publish changes in main thread
                await MainActor.run(body: {
                    self.fetchedPlaces = response.mapItems.compactMap({ item -> CLPlacemark? in
                        return item.placemark
                    })
                })
            } catch {
                // handle error
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        // handle error
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {return}
        self.userLocation = currentLocation
        self.currentLocation = CurrentLocationData(
            currentLatitude: currentLocation.coordinate.latitude,
            currentLongitude: currentLocation.coordinate.longitude
        )
        
        postToBackend(data: self.currentLocation ?? CurrentLocationData(currentLatitude: 39.13, currentLongitude: -84.52)) // coalescing to UC coords for now
    }
        
    // MARK: Location Authorization
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways: manager.requestLocation()
        case .authorizedWhenInUse: manager.requestAlwaysAuthorization()
        case .notDetermined: manager.requestAlwaysAuthorization()
        case .denied: handleLocationError()
        default: ()
        }
    }
    
    func handleLocationError() {
        // handle error
    }
        
    // MARK: Add draggable pin to MapView
    func addDraggablePin(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Significant location will be set here"
        
        mapView.addAnnotation(annotation)
    }
    
    // MARK: Enabling dragging
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "LOCATIONPIN")
        marker.isDraggable = true
        marker.canShowCallout = false
        
        return marker
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        guard let newLocation = view.annotation?.coordinate else {return}
        self.pickedLocation = .init(latitude: newLocation.latitude, longitude: newLocation.longitude)
        updatePlacemark(location: .init(latitude: newLocation.latitude, longitude: newLocation.longitude))
    }
    
    func updatePlacemark(location: CLLocation) {
        Task {
            do {
                guard let place = try await reverseLocationCoordinates(location: location) else {return}
                await MainActor.run(body: {
                    self.pickedPlacemark = place
                })
            } catch {
                // handle error
            }
        }
    }
    
    // MARK: Displaying new location data
    func reverseLocationCoordinates(location: CLLocation) async throws -> CLPlacemark? {
        let place = try await CLGeocoder().reverseGeocodeLocation(location).first
        return place
    }
}
