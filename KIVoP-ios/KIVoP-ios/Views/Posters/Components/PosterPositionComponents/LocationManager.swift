// This file is licensed under the MIT-0 License.
//
//  LocationManager.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 18.12.24.
//

import Foundation
import CoreLocation
import Combine

/// A class responsible for managing location updates and reverse geocoding
/// Uses `CLLocationManager` to fetch user location and `CLGeocoder` to retrieve the address
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
   // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var location: CLLocationCoordinate2D? // Stores the current user location as latitude and longitude
    @Published var address: String? // Stores the reverse-geocoded address
    @Published var error: String?
    
   // MARK: - Initialization
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Set high accuracy for location updates
        requestPermission()
    }
    
   // MARK: - Permission Handling
   /// Requests permission to access location while the app is in use
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
   // MARK: - Location Updates
   /// Starts updating the user's location
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
   /// Stops location updates to conserve battery
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
   
   // MARK: - CLLocationManagerDelegate Methods
       
   /// Called when new location data is available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last {
            DispatchQueue.main.async {
                self.location = newLocation.coordinate
                self.reverseGeocode(location: newLocation)
            }
        }
    }
   
   /// Called when location fetching fails, stores error description
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.error = error.localizedDescription
        }
    }
   
   // MARK: - Reverse Geocoding
       
   /// Converts a `CLLocation` into a human-readable address
    private func reverseGeocode(location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.error = error.localizedDescription
                }
            } else if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                   // Combines various address components into a single string
                    self?.address = [
                        placemark.name,
                        placemark.locality,
                        placemark.administrativeArea,
                        placemark.country
                    ].compactMap { $0 }.joined(separator: ", ")
                }
            }
        }
    }
}
