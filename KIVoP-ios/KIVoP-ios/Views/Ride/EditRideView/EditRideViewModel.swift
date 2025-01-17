import SwiftUI
import RideServiceDTOs
import CoreLocation

class EditRideViewModel: ObservableObject {
    
    private let baseURL = "https://kivop.ipv64.net"
    
    @Published var ride: GetSpecialRideDTO = GetSpecialRideDTO(name: "", starts: Date(), ends: Date(), emptySeats: 0, allocatedSeats: 0, myState: .nothing)
    
    // For Ride that gets edited
    @Published var rideDetail: GetSpecialRideDetailDTO = GetSpecialRideDetailDTO(driverName: "", isSelfDriver: false, name: "", starts: Date(), ends: Date(), startLatitude: 0, startLongitude: 0, destinationLatitude: 0, destinationLongitude: 0, emptySeats: 0, riders: [])
    
    @Published var showingLocation = false
    @Published var showingDstLocation = false
    @Published var selectedOption: String?
    @Published var isLoading: Bool = false
    @Published var isSaved: Bool = false
    @Published var address: String = ""
    @Published var dstAddress: String = ""
    
    // Alert switches
    @Published var showSaveAlert: Bool = false
    @Published var showDismissAlert: Bool = false
    
    // New Ride Vars
    @Published var eventId: UUID = UUID() // Event
    @Published var rideName: String = "" // Special
    @Published var rideDescription: String = "" // Event und Special
    @Published var starts: Date = Date() // Event und Special
    @Published var location: CLLocationCoordinate2D?
    @Published var dstLocation: CLLocationCoordinate2D?
    @Published var vehicleDescription: String = "" // Event und Special
    @Published var emptySeats: Int? = nil // Event und Special
    
    init(rideDetail: GetSpecialRideDetailDTO? = nil){
        self.rideDetail = rideDetail ?? GetSpecialRideDetailDTO(driverName: "", isSelfDriver: false, name: "", starts: Date(), ends: Date(), startLatitude: 0, startLongitude: 0, destinationLatitude: 0, destinationLongitude: 0, emptySeats: 0, riders: [])
        
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
    }
    
    // Beispieldaten:
    struct Event {
        var id: UUID
        var name: String
    }
    let events = [
        Event(id: UUID(), name: "Event 1"),
        Event(id: UUID(), name: "Event 2"),
        Event(id: UUID(), name: "Event 3")
    ]
    
    // Validierung
    var isFormValid: Bool {
        if selectedOption == "EventFahrt" {
            // Für Events
            return events.first(where: { $0.id == eventId }) != nil &&
            !rideDescription.isEmpty &&
            starts > Date() &&
            //longitude != 0 &&
            //latitude != 0 &&
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
            // EventRide
            //saveEventRide()
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
        print("EventID: \(eventId)")
        print("Empty Seats: \(emptySeats ?? 0)")
        print("Beschreibung: \(rideDescription)")
        print("Fahrzeug Beschreibung: \(vehicleDescription)")
        //print("Startkoordinaten: \(latitude) + \(longitude)")
        print("Startzeit: \(starts)")
        print("Event Fahrt gespeichert")
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
        URLSession.shared.dataTask(with: request) { [weak self] _ , response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
//            guard let data = data else {
//                print("No data received from server")
//                return
//            }

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
    case save, error
}
