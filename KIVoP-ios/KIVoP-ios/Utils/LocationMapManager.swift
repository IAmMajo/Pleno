import CoreLocation

class LocationMapManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    // Veröffentliche die aktuelle Position, damit SwiftUI auf Änderungen reagieren kann
    @Published var currentLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        // Standortberechtigung anfordern
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            DispatchQueue.main.async {
                self.currentLocation = location
            }
        }
    }
    func stopLocationUpdates() {
        // Stoppe die Standortaktualisierungen
        locationManager.stopUpdatingLocation()
        print("Standortaktualisierungen gestoppt.")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            print("Standortberechtigung abgelehnt oder eingeschränkt.")
        case .notDetermined:
            print("Berechtigung noch nicht erfragt.")
        @unknown default:
            print("Unbekannter Autorisierungsstatus.")
        }
    }

}
