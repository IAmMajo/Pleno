import Foundation
import CoreLocation
import MapKit
import RideServiceDTOs

@MainActor
class EventRideDetailViewModel: ObservableObject {
    @Published var eventRide: GetEventRideDTO
    @Published var eventRideDetail: GetEventRideDetailDTO
    @Published var eventDetails: GetEventDetailDTO
    @Published var requestedRiders: [GetRiderDTO] = []
    @Published var acceptedRiders: [GetRiderDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showDeleteRideAlert: Bool = false // Fahrer der seine Fahrt löschen will
    @Published var showPassengerDeleteRequest: Bool = false // Fahrer löscht einen Mitfahrer im nachhinein
    @Published var showPassengerAddRequest: Bool = false // Fahrer akzeptiert einen Request
    @Published var showDeleteRideRequest: Bool = false // Wenn ein Mitfahrer seinen Request zurücknehmen will
    @Published var showRiderDeleteRequest: Bool = false // Wenn ein Mitfahrer seine Fahrt löschen will
    @Published var driverAddress: String = ""
    @Published var riderAddresses: [UUID: String] = [:] // Um die Adressen für die Mitfahrer zu berechnen
    @Published var eventAddress: String = ""
    @Published var eventLocation: CLLocationCoordinate2D?
    @Published var driverLocation: CLLocationCoordinate2D?
    
    var rider: GetRiderDTO?
    
    private let baseURL = "https://kivop.ipv64.net"
    
    init(eventRide: GetEventRideDTO) {
        self.eventRide = eventRide
        self.eventDetails = GetEventDetailDTO(
            id: UUID(),
            name: "",
            starts: Date(),
            ends: Date(),
            latitude: 0,
            longitude: 0,
            participations: [],
            userWithoutFeedback: [],
            countRideInterested: 0,
            countEmptySeats: 0
        )
        self.eventRideDetail = GetEventRideDetailDTO(
            id: UUID(),
            eventID: UUID(),
            eventName: "",
            driverName: "",
            driverID: UUID(),
            isSelfDriver: false,
            starts: Date(),
            latitude: 0,
            longitude: 0,
            emptySeats: 0,
            riders: []
        )
    }
    
    func fetchEventDetails() {
        isLoading = true
        
        // Überprüfen und URL erstellen
        guard let url = URL(string: "\(baseURL)/events/\(eventRide.eventID)") else {
            print("Invalid URL")
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // JWT-Token zu den Headern hinzufügen
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Unauthorized: No token found")
            isLoading = false
            return
        }
        
        // Netzwerkaufruf starten
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // Schwache Referenz sicherstellen
            guard let self = self else { return }
            
            // Fehlerprüfung
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            // Datenprüfung
            guard let data = data else {
                print("No data received from server")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            DispatchQueue.main.async {
                do {
                    // Decodieren der Antwort in ein Array von GetSpecialRideDTO
                    let decodedEventDetails = try decoder.decode(GetEventDetailDTO.self, from: data)
                    self.eventDetails = decodedEventDetails
                    self.eventLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.eventDetails.latitude) , longitude: CLLocationDegrees(self.eventDetails.longitude))
                } catch {
                    print("JSON Decode Error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func fetchEventRideDetails() {
        Task {
            do {
                self.isLoading = true
                
                guard let url = URL(string: "\(baseURL)/eventrides/\(eventRide.id)") else {
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
                            let fetchedEventRideDetail = try decoder.decode(GetEventRideDetailDTO.self, from: data)
                            self.eventRideDetail = fetchedEventRideDetail
                            self.acceptedRiders = self.eventRideDetail.riders.filter { $0.accepted }
                            self.requestedRiders = self.eventRideDetail.riders.filter { !$0.accepted }
                            self.rider = self.eventRideDetail.riders.first(where: { $0.itsMe })
                            self.isLoading = false
                            self.driverLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.eventRideDetail.latitude) , longitude: CLLocationDegrees(self.eventRideDetail.longitude))
                            // Durchlaufe alle Fahrer und rufe die Adresse für jedes Fahrer-Standort ab
                            for rider in self.eventRideDetail.riders {
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
    
    // Fahrer löscht die Fahrt
    func deleteRide() {
        Task {
            do {
                self.isLoading = true
                
                // Hier verwenden wir die URL, die mit der speziellen rideID kombiniert wird
                guard let url = URL(string: "\(baseURL)/eventrides/\(eventRide.id)") else {
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
    
    // Mitfahrer fragt einen Sitzplatz an
    func requestEventRide() {
        Task {
            do {
                self.isLoading = true
                
                guard let url = URL(string: "\(baseURL)/eventrides/\(eventRide.id)/requests") else {
                    throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // Authorization Header hinzufügen
                if let token = UserDefaults.standard.string(forKey: "jwtToken") {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    errorMessage = "Unauthorized: Token not found."
                    self.isLoading = false
                    return
                }
                
                // Führe die Anfrage aus
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                    throw NSError(domain: "Failed to request ride", code: 500, userInfo: nil)
                }
                
                // JSON-Antwort dekodieren
                let decoder = JSONDecoder()
                let fetchedRider = try decoder.decode(GetRiderDTO.self, from: data)
                
                // Rider zur Liste hinzufügen
                DispatchQueue.main.async {
                    self.requestedRiders.append(fetchedRider)
                    self.rider = fetchedRider
                    self.isLoading = false
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
    
    // Fahrer akzeptiert einen Request
    func acceptRequestedRider(rider: GetRiderDTO) {
        Task {
            do {
                self.isLoading = true // Ladezustand aktivieren
                
                // Erstelle die URL mit der riderId
                guard let url = URL(string: "\(baseURL)/eventrides/requests/\(rider.id)") else {
                    print("Ungültige URL")
                    self.isLoading = false
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
                    "accepted": true
                ]
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
                    request.httpBody = jsonData
                } catch {
                    print("Fehler beim Erstellen des JSON-Bodys: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }
                
                // Führe die Anfrage aus
                let (data, response) = try await URLSession.shared.data(for: request)
                
                // Überprüfe die Antwort auf den Statuscode 200 (OK)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NSError(domain: "Failed to accept requested rider", code: 500, userInfo: nil)
                }
                
                // JSON-Dekodierung
                let decoder = JSONDecoder()
                let updatedRider = try decoder.decode(GetRiderDTO.self, from: data)
                
                // Erfolgreiche Bearbeitung
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let index = self.requestedRiders.firstIndex(where: { $0.id == rider.id }) {
                        self.acceptedRiders.append(updatedRider)
                        self.requestedRiders.remove(at: index)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Akzeptieren des angefragten Mitfahrers: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Fahrer entfernt einen Mitfahrer
    func removeFromPassengers(rider: GetRiderDTO) {
        Task {
            do {
                self.isLoading = true // Ladezustand aktivieren
                
                // Erstelle die URL mit der riderId
                guard let url = URL(string: "\(baseURL)/eventrides/requests/\(rider.id)") else {
                    print("Ungültige URL")
                    self.isLoading = false
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
                    "accepted": false
                ]
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
                    request.httpBody = jsonData
                } catch {
                    print("Fehler beim Erstellen des JSON-Bodys: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }
                
                // Führe die Anfrage aus
                let (data, response) = try await URLSession.shared.data(for: request)
                
                // Überprüfe die Antwort auf den Statuscode 200 (OK)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NSError(domain: "Failed to accept requested rider", code: 500, userInfo: nil)
                }
                
                // JSON-Dekodierung
                let decoder = JSONDecoder()
                let updatedRider = try decoder.decode(GetRiderDTO.self, from: data)
                
                // Erfolgreiche Bearbeitung
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let index = self.requestedRiders.firstIndex(where: { $0.id == rider.id }) {
                        self.acceptedRiders.append(updatedRider)
                        self.requestedRiders.remove(at: index)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Akzeptieren des angefragten Mitfahrers: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Löschen der Anfrage durch den Mitfahrer
    func deleteRideRequestedSeat(rider: GetRiderDTO) {
        Task {
            do {
                self.isLoading = true
                
                // Erstelle die URL mit der requestID
                guard let url = URL(string: "\(baseURL)/eventrides/requests/\(rider.id)") else {
                    print("Ungültige URL")
                    self.isLoading = false
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
                let (_, response) = try await URLSession.shared.data(for: request)
                
                // Überprüfe die Antwort auf den Statuscode 204 (No Content)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                    throw NSError(domain: "Failed to delete ride request", code: 500, userInfo: nil)
                }
                
                DispatchQueue.main.async {
                    // Erfolgreiches Löschen der Anfrage
                    self.requestedRiders.removeAll(where: { $0.id == rider.id })
                    self.acceptedRiders.removeAll(where: { $0.id == rider.id }) 
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

    
    // Funktion um Adressen zu generieren
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

            completion(addressString)
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy - HH:mm 'Uhr'"
        return formatter.string(from: date)
    }
}
