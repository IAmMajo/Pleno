import SwiftUI
import RideServiceDTOs

class NewRideViewModel: ObservableObject {
    @Published var selectedOption: String?
    private let baseURL = "https://kivop.ipv64.net"
    @Published var isLoading: Bool = false
    @Published var isSaved: Bool = false
    var ride: GetSpecialRideDTO = GetSpecialRideDTO(name: "", starts: Date(), ends: Date(), emptySeats: 0, allocatedSeats: 0, myState: .nothing)
    
    // New Ride Vars
    @Published var eventId: UUID = UUID() // Event
    @Published var rideName: String = "" // Special
    @Published var rideDescription: String = "" // Event und Special
    @Published var starts: Date = Date() // Event und Special
    @Published var latitude: Float = 0 // Event und Special
    @Published var longitude: Float = 0 // Event und Special
    @Published var dstLatitude: Float = 0 // Special
    @Published var dstLongitude: Float = 0 // Special
    @Published var vehicleDescription: String = "" // Event und Special
    @Published var emptySeats: Int? = nil // Event und Special
    
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
                   //longitude != 0 &&
                   //latitude != 0 &&
                   //dstLatitude != 0 &&
                   //dstLongitude != 0 &&
                   !vehicleDescription.isEmpty &&
                   emptySeats != nil
        }
        return true
    }
    
    // Speichern
    func saveRide() {
        if selectedOption == "EventFahrt" {
            saveEventRide()
        } else if selectedOption == "SonderFahrt"{
            saveSpecialRide()
        } else {
            print("Es konnte nicht gespeichert werden.")
        }
    }
    
    func saveEventRide(){
        print("EventID: \(eventId)")
        print("Empty Seats: \(emptySeats ?? 0)")
        print("Beschreibung: \(rideDescription)")
        print("Fahrzeug Beschreibung: \(vehicleDescription)")
        print("Startkoordinaten: \(latitude) + \(longitude)")
        print("Startzeit: \(starts)")
        print("Event Fahrt gespeichert")
    }
    
    func saveSpecialRide(){
        // Koordinaten sind Beispieldaten, da noch nicht in der View vorhanden.
        let specialRide = CreateSpecialRideDTO(
            name: rideName,
            description: rideDescription,
            vehicleDescription: vehicleDescription,
            starts: starts,
            ends: starts.addingTimeInterval(86400), // Endet nach 24 Stunden
            startLatitude: 51.5074, // latitude,
            startLongitude: -0.1278, // longitude,
            destinationLatitude: 48.8566, // dstLatitude,
            destinationLongitude: 2.3522, // dstLongitude,
            emptySeats: UInt8(emptySeats ?? 0)
        )
        
        createSpecialRide(specialRide)
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
            print("Vorm encoden : \(specialRideDTO)")
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
                self?.ride.id = specialRideDetail.id
                DispatchQueue.main.async {
                    print("Fahrt erstellt: \(specialRideDetail)")
                    self?.isSaved = true
                }
            } catch {
                // Erweiterte Fehlerbehandlung: Zeige den Fehler genau an
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

// Alert Switch fürs Speichern
enum ActiveAlert {
    case save, error
}
