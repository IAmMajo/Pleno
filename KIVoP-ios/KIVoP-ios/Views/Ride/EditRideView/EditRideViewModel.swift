import SwiftUI
import RideServiceDTOs

class EditRideViewModel: ObservableObject {
    @Published var selectedOption: String
    @Published var showSaveAlert: Bool = false // Wenn Fehler im Formular
    @Published var showDismissAlert: Bool = false // Abfrage vorm zurück gehen
    private let baseURL = "https://kivop.ipv64.net"
    @Published var isLoading: Bool = false
    @Published var isSaved: Bool = false
    @Published var ride: GetSpecialRideDetailDTO
    
    init(ride: GetSpecialRideDetailDTO, selectedOption: String){
        self.ride = ride
        self.selectedOption = selectedOption
    }

    // Validierung
    var isFormValid: Bool {
        if selectedOption == "EventFahrt" {
//            // Für Events
//            return events.first(where: { $0.id == eventId }) != nil &&
//                   !rideDescription.isEmpty &&
//                   starts > Date() &&
//                   //longitude != 0 &&
//                   //latitude != 0 &&
//                   !vehicleDescription.isEmpty &&
//                   emptySeats != nil
        } else if selectedOption == "SonderFahrt" {
            // Für Sonderfahrten
            return !ride.name.isEmpty &&
                   ride.description != "" &&
                   ride.starts > Date() &&
                   //longitude != 0 &&
                   //latitude != 0 &&
                   //dstLatitude != 0 &&
                   //dstLongitude != 0 &&
                   ride.vehicleDescription != "" &&
                   ride.emptySeats > 0
        }
        return true
    }
    
    // Speichern
    func saveRide() {
        if selectedOption == "EventFahrt" {
            //saveEventRide()
        } else if selectedOption == "SonderFahrt"{
            saveSpecialRide()
        } else {
            print("Es konnte nicht gespeichert werden.")
        }
    }
    
//    func saveEventRide(){
//        print("EventID: \(eventId)")
//        print("Empty Seats: \(emptySeats ?? 0)")
//        print("Beschreibung: \(rideDescription)")
//        print("Fahrzeug Beschreibung: \(vehicleDescription)")
//        print("Startkoordinaten: \(latitude) + \(longitude)")
//        print("Startzeit: \(starts)")
//        print("Event Fahrt gespeichert")
//    }
    
    func saveSpecialRide(){
        // Koordinaten sind Beispieldaten, da noch nicht in der View vorhanden.
        let specialRide = PatchSpecialRideDTO(
            name: ride.name,
            description: ride.description,
            vehicleDescription: ride.vehicleDescription,
            starts: ride.starts,
            ends: ride.starts.addingTimeInterval(86400), // Endet nach 24 Stunden
            startLatitude: 51.5074, // latitude,
            startLongitude: -0.1278, // longitude,
            destinationLatitude: 48.8566, // dstLatitude,
            destinationLongitude: 2.3522, // dstLongitude,
            emptySeats: ride.emptySeats
        )
        
        editSpecialRide(specialRide)
    }
    
    // POST-Request zum Erstellen einer Sonderfahrt
    func editSpecialRide(_ specialRideDTO: PatchSpecialRideDTO) {
        self.isLoading = true

        guard let url = URL(string: "\(baseURL)/specialrides/\(ride.id ?? UUID())") else {
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

        }.resume()
    }
}
