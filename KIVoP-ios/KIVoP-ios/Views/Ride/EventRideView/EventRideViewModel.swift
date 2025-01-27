import Foundation
import CoreLocation
import RideServiceDTOs

class EventRideViewModel: ObservableObject {
    @Published var event: GetEventDTO
    @Published var eventDetails: GetEventDetailDTO?
    @Published var eventRides: [GetEventRideDTO] = []
    @Published var isLoading: Bool = false // Standardmäßig nicht ladend
    
    @Published var address: String = ""
    @Published var driverAddress: [UUID: String] = [:]
    
    private let baseURL = "https://kivop.ipv64.net"
    
    init(event: GetEventDTO) {
        self.event = event
    }
    
    // Weitere Details zum Event bekommen
    func fetchEventDetails() {
        guard let url = URL(string: "\(baseURL)/events/\(event.id)") else {
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
            
            do {
                // Decodieren der Antwort
                let decodedEventDetails = try decoder.decode(GetEventDetailDTO.self, from: data)
                DispatchQueue.main.async {
                    self.eventDetails = decodedEventDetails
                    self.isLoading = false // Ladevorgang erfolgreich beendet
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false // Ladevorgang beendet, aber mit JSON-Fehler
                }
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // Alle Event Fahrten bekommen
    func fetchEventRides() {
        guard let url = URL(string: "\(baseURL)/eventrides?byEventID=\(event.id)") else {
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
            
            do {
                // Decodieren der Antwort
                let decodedEventRides = try decoder.decode([GetEventRideDTO].self, from: data)
                DispatchQueue.main.async {
                    self.eventRides = decodedEventRides
                    self.isLoading = false // Ladevorgang erfolgreich beendet
                    for ride in self.eventRides {
                        self.getAddressFromCoordinates(latitude: ride.latitude, longitude: ride.longitude) { address in
                            if let address = address {
                                // Speichere die Adresse im Dictionary mit der Rider ID als Schlüssel
                                self.driverAddress[ride.driverID] = address
                            }
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false // Ladevorgang beendet, aber mit JSON-Fehler
                }
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func participateEvent() {
        self.isLoading = true
        
        guard let url = URL(string: "\(baseURL)/events/\(event.id)/participations") else {
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
                    self.event.myState = .present
                    self.isLoading = false
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
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy - HH:mm 'Uhr'"
        return formatter.string(from: date)
    }
}
