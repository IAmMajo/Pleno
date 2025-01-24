import Foundation
import CoreLocation
import MapKit
import RideServiceDTOs

@MainActor
class RideDetailViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedOption: String // Für EventDetails anpassen
    @Published var rideDetail: GetSpecialRideDetailDTO
    @Published var requestedRiders: [GetRiderDTO] = []
    @Published var acceptedRiders: [GetRiderDTO] = []
    @Published var showDeleteRideAlert: Bool = false // Fahrer der seine Fahrt löschen will
    @Published var showPassengerDeleteRequest: Bool = false // Fahrer löscht einen Mitfahrer im nachhinein
    @Published var showPassengerAddRequest: Bool = false // Fahrer akzeptiert einen Request
    @Published var showDeleteRideRequest: Bool = false // Wenn ein Mitfahrer seinen Request zurücknehmen will
    @Published var showRiderDeleteRequest: Bool = false // Wenn ein Mitfahrer seine Fahrt löschen will
    @Published var showLocationRequest: Bool = false // sheet um die Location festzulegen vor einer Anfrage
    @Published var requestLat: Float = 0
    @Published var requestLong: Float = 0
    @Published var driverAddress: String = ""
    @Published var requestedAdress: String = "" // Adresse für die Anzeige beim Auswählen der Location für einen Mitfahrer
    @Published var riderAddresses: [UUID: String] = [:] // Um die Adressen für die Mitfahrer zu berechnen
    @Published var destinationAddress: String = ""
    @Published var location: CLLocationCoordinate2D?
    @Published var requestedLocation: CLLocationCoordinate2D? // Location für die Anfrage
    @Published var startLocation: CLLocationCoordinate2D?
    
    private let baseURL = "https://kivop.ipv64.net"
    var ride: GetSpecialRideDTO
    var rider: GetRiderDTO?
    
    init(ride: GetSpecialRideDTO) {
        self.ride = ride
        self.selectedOption = "SonderFahrt"
        self.rideDetail = GetSpecialRideDetailDTO(
            id: nil,
            driverName: "",
            driverID: UUID(),
            isSelfDriver: false,
            name: "",
            description: nil,
            vehicleDescription: nil,
            starts: Date(),
            ends: Date(),
            startLatitude: 0.0,
            startLongitude: 0.0,
            destinationLatitude: 0.0,
            destinationLongitude: 0.0,
            emptySeats: 0,
            riders: []
        )
    }
    
    func fetchRideDetails() {
        Task {
            do {
                self.isLoading = true
                
                guard let rideID = ride.id?.uuidString,
                      let url = URL(string: "https://kivop.ipv64.net/specialrides/\(rideID)") else {
                    throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                if let token = UserDefaults.standard.string(forKey: "jwtToken") {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    errorMessage = "Unauthorized: Token not found."
                    self.isLoading = false
                    return
                }
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NSError(domain: "Failed to fetch ride details", code: 500, userInfo: nil)
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    DispatchQueue.main.async {
                        do {
                            // Dekodiere ein einzelnes Objekt anstelle eines Arrays
                            let fetchedRideDetail = try decoder.decode(GetSpecialRideDetailDTO.self, from: data)
                            self.rideDetail = fetchedRideDetail
                            self.groupRiders()
                            self.rider = self.rideDetail.riders.first(where: { $0.itsMe })
                            self.isLoading = false
                            self.location = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.rideDetail.destinationLatitude) , longitude: CLLocationDegrees(self.rideDetail.destinationLongitude) )
                            self.startLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.rideDetail.startLatitude), longitude: CLLocationDegrees(self.rideDetail.startLongitude))
                            // Durchlaufe alle Fahrer und rufe die Adresse für jedes Fahrer-Standort ab
                            for rider in self.rideDetail.riders {
                                self.getAddressFromCoordinates(latitude: rider.latitude, longitude: rider.longitude) { address in
                                    if let address = address {
                                        // Speichere die Adresse im Dictionary mit der Rider ID als Schlüssel
                                        self.riderAddresses[rider.id] = address
                                    }
                                }
                            }
                        } catch {
                            print("Fehler beim Dekodieren der Ride Details: \(error.localizedDescription)")
                            self.isLoading = false
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    func deleteRide() {
        Task {
            do {
                self.isLoading = true
                
                // Hier verwenden wir die URL, die mit der speziellen rideID kombiniert wird
                guard let rideID = ride.id?.uuidString,
                      let url = URL(string: "https://kivop.ipv64.net/specialrides/\(rideID)") else {
                    throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "DELETE" // Setze die HTTP-Methode auf DELETE
                
                // Authorization Header hinzufügen
                if let token = UserDefaults.standard.string(forKey: "jwtToken") {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    errorMessage = "Unauthorized: Token not found."
                    self.isLoading = false
                    return
                }
                
                // Führe die Anfrage aus
                let (_, response) = try await URLSession.shared.data(for: request)
                
                // Überprüfe die Antwort auf den Statuscode 204
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                    throw NSError(domain: "Failed to delete ride", code: 500, userInfo: nil)
                }
                
                DispatchQueue.main.async {
                    // Erfolgreiches Löschen
                    if let index = self.requestedRiders.firstIndex(where: { $0.itsMe }) {
                        self.requestedRiders.remove(at: index)
                    }
                    self.isLoading = false
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    // Fehlerbehandlung hier
                    print("Fehler beim Löschen der Fahrt: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func requestRide() {
        Task {
            do {
                self.isLoading = true
                
                // Hier verwenden wir die URL, die mit der speziellen rideID kombiniert wird
                guard let rideID = ride.id?.uuidString,
                      let url = URL(string: "https://kivop.ipv64.net/specialrides/\(rideID)/requests") else {
                    throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST" // Setze die HTTP-Methode auf POST
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // Authorization Header hinzufügen
                if let token = UserDefaults.standard.string(forKey: "jwtToken") {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    errorMessage = "Unauthorized: Token not found."
                    self.isLoading = false
                    return
                }
                
                let requestDTO = CreateSpecialRideRequestDTO(
                    latitude: requestLat,
                    longitude: requestLong
                )
                
                // Konvertiere den Body in JSON
                let jsonData = try JSONEncoder().encode(requestDTO)
                request.httpBody = jsonData
                
                // Führe die Anfrage aus
                let (data, response) = try await URLSession.shared.data(for: request)
                
                // Überprüfe die Antwort auf den Statuscode 200 (OK)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                    throw NSError(domain: "Failed to request ride", code: 500, userInfo: nil)
                }
                
                do {
                    let decoder = JSONDecoder()
                    
                    DispatchQueue.main.async {
                        do {
                            let fetchedRider = try decoder.decode(GetRiderDTO.self, from: data)
                            self.requestedRiders.append(fetchedRider)
                            self.rider = fetchedRider
                            self.isLoading = false
                        } catch {
                            print("Fehler beim Dekodieren der Ride Details: \(error.localizedDescription)")
                            self.isLoading = false
                        }
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    // Fehlerbehandlung hier
                    print("Fehler beim Anfordern der Fahrt: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Löschen der Anfrage, und der Mitnahme für Fahrer und Mitfahrer
    func deleteRideRequestedSeat(rider: GetRiderDTO) {
        // Erstelle die URL mit der requestID
        guard let url = URL(string: "https://kivop.ipv64.net/specialrides/requests/\(rider.id)") else {
            print("Ungültige URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE" // Setze die HTTP-Methode auf DELETE
        
        // Authorization Header hinzufügen
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            errorMessage = "Unauthorized: Token not found."
            self.isLoading = false
            return
        }
        
        // Führe die Anfrage aus
        Task {
            do {
                self.isLoading = true
                
                let (_, response) = try await URLSession.shared.data(for: request)
                
                // Überprüfe die Antwort auf den Statuscode 204 (No Content)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                    throw NSError(domain: "Failed to delete ride request", code: 500, userInfo: nil)
                }
                
                DispatchQueue.main.async {
                    // Erfolgreiches Löschen der Anfrage
                    self.isLoading = false
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    // Fehlerbehandlung
                    print("Fehler beim Löschen der Anfrage: \(error.localizedDescription)")
                }
            }
        }
    }
      
    func acceptRequestedRider(rider: GetRiderDTO) {
        // Erstelle die URL mit der riderId
        guard let url = URL(string: "https://kivop.ipv64.net/specialrides/requests/\(rider.id)") else {
            print("Ungültige URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH" // Setze die HTTP-Methode auf PATCH
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Authorization Header hinzufügen
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            errorMessage = "Unauthorized: Token not found."
            self.isLoading = false
            return
        }
        
        // Der Body für den Request
        let body: [String: Any] = [
            "longitude": rider.longitude,
            "latitude": rider.latitude,
            "accepted": true
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            print("Fehler beim Erstellen des JSON-Bodys: \(error.localizedDescription)")
            return
        }
        
        // Führe die Anfrage aus
        Task {
            do {
                self.isLoading = true
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                // Überprüfe die Antwort auf den Statuscode 200 (OK)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NSError(domain: "Failed to accept requested rider", code: 500, userInfo: nil)
                }
                
                do {
                    let decoder = JSONDecoder()
                    let updatedRider = try decoder.decode(GetRiderDTO.self, from: data)
                    
                    DispatchQueue.main.async {
                        // Erfolgreiche Annahme der Anfrage
                        self.isLoading = false
                        // Aktualisiere den Rider in der Liste der angefragten Mitfahrer
                        if let index = self.requestedRiders.firstIndex(where: { $0.id == rider.id }) {
                            self.acceptedRiders.append(updatedRider)
                            self.requestedRiders.remove(at: index)
                        }
                    }
                    
                } catch {
                    print("Fehler beim Dekodieren der Antwort: \(error.localizedDescription)")
                    self.isLoading = false
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    // Fehlerbehandlung
                    print("Fehler beim Akzeptieren des angefragten Mitfahrers: \(error.localizedDescription)")
                }
            }
        }
    }

    func removeFromPassengers(rider: GetRiderDTO) {
        // Erstelle die URL mit der riderId
        guard let url = URL(string: "https://kivop.ipv64.net/specialrides/requests/\(rider.id)") else {
            print("Ungültige URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH" // Setze die HTTP-Methode auf PATCH
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Authorization Header hinzufügen
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            errorMessage = "Unauthorized: Token not found."
            self.isLoading = false
            return
        }
        
        // Der Body für den Request
        let body: [String: Any] = [
            "longitude": rider.longitude,
            "latitude": rider.latitude,
            "accepted": false
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            print("Fehler beim Erstellen des JSON-Bodys: \(error.localizedDescription)")
            return
        }
        
        // Führe die Anfrage aus
        Task {
            do {
                self.isLoading = true
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                // Überprüfe die Antwort auf den Statuscode 200 (OK)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NSError(domain: "Failed to accept requested rider", code: 500, userInfo: nil)
                }
                
                do {
                    let decoder = JSONDecoder()
                    let updatedRider = try decoder.decode(GetRiderDTO.self, from: data)
                    
                    DispatchQueue.main.async {
                        // Erfolgreiche Annahme der Anfrage
                        self.isLoading = false
                        // Aktualisiere den Rider in der Liste der angefragten Mitfahrer
                        if let index = self.acceptedRiders.firstIndex(where: { $0.id == rider.id }) {
                            self.acceptedRiders.remove(at: index)
                            self.requestedRiders.append(updatedRider)
                        }
                    }
                    
                } catch {
                    print("Fehler beim Dekodieren der Antwort: \(error.localizedDescription)")
                    self.isLoading = false
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    // Fehlerbehandlung
                    print("Fehler beim Akzeptieren des angefragten Mitfahrers: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getAddressFromCoordinates(latitude: Float, longitude: Float, completion: @escaping (String?) -> Void) {
        let clLocation = CLLocation(latitude: Double(latitude), longitude: Double(longitude))
        
        CLGeocoder().reverseGeocodeLocation(clLocation) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?.first else {
                completion(nil)
                return
            }
            
            var addressString = ""
            if let name = placemark.name {
                addressString += name
            }
            if let postalCode = placemark.postalCode {
                addressString += ", \(postalCode)"
            }
            if let city = placemark.locality {
                addressString += " \(city)"
            }
//            if let country = placemark.country {
//                addressString += ", \(country)"
//            }
            
            completion(addressString)
        }
    }

    func groupRiders(){
        // aufteilen in Gruppen für die View
        acceptedRiders = rideDetail.riders.filter { $0.accepted }
        requestedRiders = rideDetail.riders.filter { !$0.accepted }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy - HH:mm 'Uhr'"
        return formatter.string(from: date)
    }
}
