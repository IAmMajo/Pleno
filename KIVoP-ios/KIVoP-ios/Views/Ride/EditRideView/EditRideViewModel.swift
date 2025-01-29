import SwiftUI
import RideServiceDTOs
import CoreLocation

class EditRideViewModel: ObservableObject {
    
    private let baseURL = "https://kivop.ipv64.net"
    
    @Published var ride: GetSpecialRideDTO = GetSpecialRideDTO(id: UUID(), name: "", starts: Date(), ends: Date(), emptySeats: 0, allocatedSeats: 0, myState: .nothing)
    
    // SpecialRide der Bearbeitet wird
    @Published var rideDetail: GetSpecialRideDetailDTO = GetSpecialRideDetailDTO(id: UUID(), driverName: "", driverID: UUID(), isSelfDriver: false, name: "", starts: Date(), ends: Date(), startLatitude: 0, startLongitude: 0, destinationLatitude: 0, destinationLongitude: 0, emptySeats: 0, riders: [])
    
    // EventRide der Bearbeitet wird
    @Published var eventRideDetail: GetEventRideDetailDTO = GetEventRideDetailDTO(id: UUID(), eventID: UUID(), eventName: "", driverName: "", driverID: UUID(), isSelfDriver: false, starts: Date(), latitude: 0, longitude: 0, emptySeats: 0, riders: [])
    
    
    @Published var showingLocation = false
    @Published var showingDstLocation = false
    @Published var selectedOption: String?
    @Published var isLoading: Bool = false
    @Published var isSaved: Bool = false
    @Published var address: String = ""
    @Published var dstAddress: String = ""
    
    // Für Events
    @Published var events: [GetEventDTO] = []
    @Published var eventDetails: GetEventDetailDTO?
    @Published var selectedEventId: UUID?
    @Published var eventRide: GetEventRideDTO?
    
    // Alert switches
    @Published var showSaveAlert: Bool = false
    @Published var showDismissAlert: Bool = false
    
    // New Ride Vars
    @Published var rideName: String = "" // Special
    @Published var rideDescription: String = "" // Event und Special
    @Published var starts: Date = Date() // Event und Special
    @Published var location: CLLocationCoordinate2D?
    @Published var dstLocation: CLLocationCoordinate2D?
    @Published var vehicleDescription: String = "" // Event und Special
    @Published var emptySeats: Int? = nil // Event und Special
    
    init(rideDetail: GetSpecialRideDetailDTO? = nil, eventRideDetail: GetEventRideDetailDTO? = nil){
        self.rideDetail = rideDetail ?? GetSpecialRideDetailDTO(id: UUID(), driverName: "", driverID: UUID(), isSelfDriver: false, name: "", starts: Date(), ends: Date(), startLatitude: 0, startLongitude: 0, destinationLatitude: 0, destinationLongitude: 0, emptySeats: 0, riders: [])
        
        self.eventRideDetail = eventRideDetail ?? GetEventRideDetailDTO(id: UUID(), eventID: UUID(), eventName: "", driverName: "", driverID: UUID(), isSelfDriver: false, starts: Date(), latitude: 0, longitude: 0, emptySeats: 0, riders: [])
        
        if self.rideDetail.startLatitude != 0 && self.rideDetail.startLongitude != 0 {
              self.location = CLLocationCoordinate2D(
                latitude: CLLocationDegrees(self.rideDetail.startLatitude),
                longitude: CLLocationDegrees(self.rideDetail.startLongitude)
              )
          }
        
        if self.rideDetail.destinationLatitude != 0 && self.rideDetail.destinationLongitude != 0 {
            self.dstLocation = CLLocationCoordinate2D(
                latitude: CLLocationDegrees(self.rideDetail.destinationLatitude),
                longitude: CLLocationDegrees(self.rideDetail.destinationLongitude)
            )
        }
        
        if self.eventRideDetail.latitude != 0 && self.eventRideDetail.longitude != 0 {
            self.location = CLLocationCoordinate2D(
                latitude: CLLocationDegrees(self.eventRideDetail.latitude),
                longitude: CLLocationDegrees(self.eventRideDetail.longitude)
            )
        }
    }
    
    // Validierung
    var isFormValid: Bool {
        if selectedOption == "EventFahrt" {
            // Für Events
            return starts > Date() &&
            location?.longitude != 0 &&
            location?.latitude != 0 &&
            !vehicleDescription.isEmpty &&
            emptySeats != nil
        } else if selectedOption == "SonderFahrt" {
            // Für Sonderfahrten
            return !rideName.isEmpty &&
            !rideDescription.isEmpty &&
            starts > Date() &&
            location?.longitude != 0 &&
            location?.latitude != 0 &&
            dstLocation?.latitude != 0 &&
            dstLocation?.longitude != 0 &&
            !vehicleDescription.isEmpty &&
            emptySeats != nil
        }
        return true
    }
    
    // Neu anlegen
    func saveRide() {
        if selectedOption == "EventFahrt" {
            saveEventRide()
        } else if selectedOption == "SonderFahrt"{
            saveSpecialRide()
        } else {
            print("Es konnte nicht gespeichert werden.")
        }
    }
    
    // Speichern
    func saveEditedRide() {
        if selectedOption == "EventFahrt" {
            saveEditedEventRide()
        } else if selectedOption == "SonderFahrt"{
            saveEditedSpecialRide()
        } else {
            print("Es konnte nicht gespeichert werden.")
        }
    }
    
    func saveSpecialRide(){
        // Koordinaten sind Beispieldaten, da noch nicht in der View vorhanden.
        let specialRide = CreateSpecialRideDTO(
            name: rideName,
            description: rideDescription,
            vehicleDescription: vehicleDescription,
            starts: starts,
            ends: starts.addingTimeInterval(86400), // Endet nach 24 Stunden
            startLatitude: Float(location!.latitude),
            startLongitude: Float(location!.longitude),
            destinationLatitude: Float(dstLocation!.latitude),
            destinationLongitude: Float(dstLocation!.longitude),
            emptySeats: UInt8(emptySeats ?? 0)
        )
        createSpecialRide(specialRide)
    }
    
    func saveEditedSpecialRide(){
        // Koordinaten sind Beispieldaten, da noch nicht in der View vorhanden.
        let specialRide = PatchSpecialRideDTO(
            name: rideDetail.name,
            description: rideDetail.description,
            vehicleDescription: rideDetail.vehicleDescription,
            starts: rideDetail.starts,
            ends: rideDetail.starts.addingTimeInterval(86400), // Endet nach 24 Stunden
            startLatitude: Float(location!.latitude),
            startLongitude: Float(location!.longitude),
            destinationLatitude: Float(dstLocation!.latitude),
            destinationLongitude: Float(dstLocation!.longitude),
            emptySeats: rideDetail.emptySeats
        )
        editSpecialRide(specialRide)
    }
    
    func saveEventRide(){
        let eventRide = CreateEventRideDTO(
            eventID: selectedEventId!,
            description: rideDescription,
            vehicleDescription: vehicleDescription,
            starts: starts,
            latitude: Float(location!.latitude),
            longitude: Float(location!.longitude),
            emptySeats: UInt8(emptySeats ?? 0)
        )
        createEventRide(eventRide)
    }
    
    func saveEditedEventRide(){
        let eventRide = PatchEventRideDTO(
            description: eventRideDetail.description,
            vehicleDescription: eventRideDetail.vehicleDescription,
            starts: eventRideDetail.starts,
            latitude: Float(location!.latitude),
            longitude: Float(location!.longitude),
            emptySeats: eventRideDetail.emptySeats
        )
        editEventRide(eventRide)
    }

    
    // Fetch Event Details für ein ausgewähltes Event um die Details im Create anzuzeigen
    func fetchEventDetails(eventID: UUID) {
        guard let url = URL(string: "\(baseURL)/events/\(eventID)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Füge JWT Token zu den Headern hinzu
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Unauthorized: No token found")
            return
        }
        
        // Führe den Netzwerkaufruf aus
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received from server")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                // Decodieren der Antwort in ein Array von GetEventDetailDTO
                let decodedEventDetails = try decoder.decode(GetEventDetailDTO.self, from: data)
                
                DispatchQueue.main.async {
                    self?.eventDetails = decodedEventDetails
                }
            } catch {
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // Alle Event Fahrten bekommen
    func fetchEventRides() {
        guard let eventID = selectedEventId,
            let url = URL(string: "\(baseURL)/eventrides?byEventID=\(eventID)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Füge JWT Token zu den Headern hinzu
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Unauthorized: No token found")
            return
        }
        
        // Setze den Ladevorgang auf true
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        // Führe den Netzwerkaufruf aus
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Behandle Fehler
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false // Ladevorgang beendet, auch bei Fehlern
                }
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.isLoading = false // Ladevorgang beendet, keine Daten
                }
                print("No data received from server")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
     
            DispatchQueue.main.async {
                do {
                    // Decodieren der Antwort
                    let decodedEventRides = try decoder.decode([GetEventRideDTO].self, from: data)
                    self.eventRide = decodedEventRides.first { $0.myState == .driver }
                    self.isLoading = false // Ladevorgang erfolgreich beendet
                } catch {
                    DispatchQueue.main.async {
                        self.isLoading = false // Ladevorgang beendet, aber mit JSON-Fehler
                    }
                    print("JSON Decode Error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    // POST-Request zum Erstellen einer Sonderfahrt
    func editSpecialRide(_ specialRideDTO: PatchSpecialRideDTO) {
        self.isLoading = true

        guard let url = URL(string: "\(baseURL)/specialrides/\(rideDetail.id ?? UUID())") else {
            print("Invalid URL")
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Füge JWT Token hinzu oder beende bei Fehler
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            print("Unauthorized: No token found")
            self.isLoading = false
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        // Setze den Request-Body mit den DTO-Daten
        do {
            let jsonData = try encoder.encode(specialRideDTO)
            request.httpBody = jsonData
        } catch {
            print("Error encoding DTO: \(error.localizedDescription)")
            self.isLoading = false
            return
        }
        
        // Führe den Netzwerkaufruf aus
        URLSession.shared.dataTask(with: request) { [weak self] data , response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received from server")
                return
            }
            
            // Debugging: Zeige die Antwort als String
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Server Response: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                // Decodieren der Antwort in ein GetSpecialRideDetailDTO
                let specialRideDetail = try decoder.decode(GetSpecialRideDetailDTO.self, from: data)
                DispatchQueue.main.async {
                    self?.ride.id = specialRideDetail.id
                    self?.isSaved = true
                }
            } catch {
                // Erweiterte Fehlerbehandlung: Zeige den Fehler genau an
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // POST-Request zum Erstellen einer Sonderfahrt
    func createSpecialRide(_ specialRideDTO: CreateSpecialRideDTO) {
        self.isLoading = true
        
        guard let url = URL(string: "\(baseURL)/specialrides") else {
            print("Invalid URL")
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Füge JWT Token hinzu oder beende bei Fehler
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            print("Unauthorized: No token found")
            self.isLoading = false
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        // Setze den Request-Body mit den DTO-Daten
        do {
            let jsonData = try encoder.encode(specialRideDTO)
            request.httpBody = jsonData
        } catch {
            print("Error encoding DTO: \(error.localizedDescription)")
            self.isLoading = false
            return
        }
        
        // Führe den Netzwerkaufruf aus
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received from server")
                return
            }
            
            // Debugging: Zeige die Antwort als String
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Server Response: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                // Decodieren der Antwort in ein GetSpecialRideDetailDTO
                let specialRideDetail = try decoder.decode(GetSpecialRideDetailDTO.self, from: data)
                DispatchQueue.main.async {
                    self?.ride.id = specialRideDetail.id
                    self?.isSaved = true
                }
            } catch {
                // Erweiterte Fehlerbehandlung: Zeige den Fehler genau an
                print("JSON Decode Error: \(error.localizedDescription)")
            }

        }.resume()
    }
    
    func editEventRide(_ eventRideDTO: PatchEventRideDTO){
        self.isLoading = true
        
        guard let url = URL(string: "\(baseURL)/eventrides/\(eventRideDetail.id)") else {
            print("Invalid URL")
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Füge JWT Token hinzu oder beende bei Fehler
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            print("Unauthorized: No token found")
            self.isLoading = false
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        // Setze den Request-Body mit den DTO-Daten
        do {
            let jsonData = try encoder.encode(eventRideDTO)
            request.httpBody = jsonData
        } catch {
            print("Error encoding DTO: \(error.localizedDescription)")
            self.isLoading = false
            return
        }
        
        // Führe den Netzwerkaufruf aus
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received from server")
                return
            }
            
            // Debugging: Zeige die Antwort als String
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Server Response: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                // Decodieren der Antwort in ein GetEventRideDetailDTO
                let eventRideDetail = try decoder.decode(GetEventRideDTO.self, from: data)
                DispatchQueue.main.async {
                    self?.ride.id = eventRideDetail.id
                    self?.isSaved = true
                }
            } catch {
                // Erweiterte Fehlerbehandlung: Zeige den Fehler genau an
                print("JSON Decode Error: \(error.localizedDescription)")
            }

        }.resume()
    }
    
    // POST-Request zum Erstellen einer Sonderfahrt
    func createEventRide(_ eventRideDTO: CreateEventRideDTO) {
        self.isLoading = true
        
        guard let url = URL(string: "\(baseURL)/eventrides") else {
            print("Invalid URL")
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Füge JWT Token hinzu oder beende bei Fehler
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            print("Unauthorized: No token found")
            self.isLoading = false
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        // Setze den Request-Body mit den DTO-Daten
        do {
            let jsonData = try encoder.encode(eventRideDTO)
            request.httpBody = jsonData
        } catch {
            print("Error encoding DTO: \(error.localizedDescription)")
            self.isLoading = false
            return
        }
        
        // Führe den Netzwerkaufruf aus
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received from server")
                return
            }
            
            // Debugging: Zeige die Antwort als String
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Server Response: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                // Decodieren der Antwort in ein GetEventRideDetailDTO
                let eventRideDetail = try decoder.decode(GetEventRideDTO.self, from: data)
                DispatchQueue.main.async {
                    self?.ride.id = eventRideDetail.id
                    self?.isSaved = true
                }
            } catch {
                // Erweiterte Fehlerbehandlung: Zeige den Fehler genau an
                print("JSON Decode Error: \(error.localizedDescription)")
            }

        }.resume()
    }
    
    func participateEvent(eventId: UUID) {
        self.isLoading = true
        
        guard let url = URL(string: "\(baseURL)/events/\(eventId)/participations") else {
            print("Invalid URL")
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Füge JWT Token hinzu oder beende bei Fehler
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            print("Unauthorized: No token found")
            self.isLoading = false
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = ["participates": true]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
        } catch {
            print("Fehler beim Serialisieren des JSON: \(error.localizedDescription)")
            self.isLoading = false
            return
        }
        
        // Führe den Netzwerkaufruf aus
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received from server")
                return
            }
            
            // Debugging: Zeige die Antwort als String
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Server Response: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if let index = self.events.firstIndex(where: { $0.id == self.selectedEventId }) {
                        self.events[index].myState = .present
                    }
                }
            }
        }.resume()
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
}

// Alert Switch fürs Speichern
enum ActiveAlert {
    case save, error, participate
}
