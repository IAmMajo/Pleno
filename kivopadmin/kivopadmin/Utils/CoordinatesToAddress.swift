import CoreLocation

public func convertCoordinatesToAddress(latitude: Double, longitude: Double, completion: @escaping (String?, Error?) -> Void) {
    let geocoder = CLGeocoder()
    let location = CLLocation(latitude: latitude, longitude: longitude)
    
    geocoder.reverseGeocodeLocation(location) { placemarks, error in
        if let error = error {
            completion(nil, error)
            return
        }
        
        if let placemark = placemarks?.first {
            var address = ""
            if let name = placemark.name {
                address += name
            }
            if let street = placemark.thoroughfare {
                address += (address.isEmpty ? "" : ", ") + street
            }
            if let city = placemark.locality {
                address += (address.isEmpty ? "" : ", ") + city
            }
            if let state = placemark.administrativeArea {
                address += (address.isEmpty ? "" : ", ") + state
            }
            if let postalCode = placemark.postalCode {
                address += (address.isEmpty ? "" : " ") + postalCode
            }
            if let country = placemark.country {
                address += (address.isEmpty ? "" : ", ") + country
            }
            completion(address, nil)
        } else {
            completion(nil, NSError(domain: "GeocodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Keine Adresse gefunden"]))
        }
    }
}
