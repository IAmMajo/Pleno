import Foundation
import SwiftUI
import RideServiceDTOs

class RideViewModel: ObservableObject {
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var selectedTab: Int = 0
    @Published var isLoading: Bool = false
    @Published var rides: [GetSpecialRideDTO] = []
    @Published var events: [GetEventDTO] = []
    private let baseURL = "https://kivop.ipv64.net"
    
    init() {
        // Konfigurieren der Navbar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    func fetchRides(){
        fetchSpecialRides()
    }
    
    func fetchSpecialRides() {
        // URL für die Route GET /specialrides
        guard let url = URL(string: "\(baseURL)/specialrides") else {
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
                // Decodieren der Antwort in ein Array von GetSpecialRideDTO
                let decodedRides = try decoder.decode([GetSpecialRideDTO].self, from: data)
                
                // Sicherstellen, dass die Updates im Main-Thread ausgeführt werden
                DispatchQueue.main.async {
                    self?.rides = []
                    self?.rides = decodedRides // Array mit den Sonderfahrten speichern
                }
            } catch {
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // Fetch Events für die Auswahl im Array
    func fetchEvents() {
        guard let url = URL(string: "\(baseURL)/events") else {
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
                // Decodieren der Antwort in ein Array von GetSpecialRideDTO
                let decodedEvents = try decoder.decode([GetEventDTO].self, from: data)
                print(decodedEvents)
                
                // Sicherstellen, dass die Updates im Main-Thread ausgeführt werden
                DispatchQueue.main.async {
                    self?.events = []
                    self?.events = decodedEvents // Array mit den Sonderfahrten speichern
                }
            } catch {
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // Gruppiert die Fahrten nach Monat und Jahr
    var groupedRides: [Dictionary<String, [GetSpecialRideDTO]>.Element] {
        let filtered = filteredRides()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM - yyyy"

        // Gruppierung
        var grouped = Dictionary(grouping: filtered) { ride in
            dateFormatter.string(from: ride.starts)
        }

        // Sortierung innerhalb der Gruppen
        for (key, rides) in grouped {
            grouped[key] = rides.sorted { lhs, rhs in
                return lhs.starts < rhs.starts // Sortiert immer aufsteigend nach dem Startdatum
            }
        }

        // Sortierung der Gruppen
        return grouped.sorted { lhs, rhs in
            guard let lhsDate = dateFormatter.date(from: lhs.key),
                  let rhsDate = dateFormatter.date(from: rhs.key) else {
                return lhs.key < rhs.key
            }
            return lhsDate < rhsDate // Sortiert die Gruppen nach Monat/Jahr
        }
    }

    // Filtert Rides basierend auf dem Tab
    private func filteredRides() -> [GetSpecialRideDTO] {
        switch selectedTab {
        case 0:
            return [] // Events -> drauf klicken um die Fahrten zum Event zu sehen
        case 1:
            return rides // Sonstige Fahrten (Fahrten die keinem Event zugehören)
        case 2:
            return rides.filter { $0.myState != .nothing } // Alle Fahrten, (Event Fahrten und Sonstige) bei denen mein Status nicht .nothing ist
        default:
            return []
        }
    }
}
