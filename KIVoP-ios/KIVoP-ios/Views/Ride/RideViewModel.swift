import Foundation
import SwiftUI
import RideServiceDTOs

class RideViewModel: ObservableObject {
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var selectedTab: Int = 0
    @Published var isLoading: Bool = false
    @Published var rides: [GetSpecialRideDTO] = []
    @Published var eventRides: [GetEventRideDTO] = []
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
        fetchEvents()
        fetchEventRides()
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
    
    // Fetch alle EventRides für die Auswahl im Array
    func fetchEventRides() {
        guard let url = URL(string: "\(baseURL)/eventrides") else {
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
                let decodedEventRides = try decoder.decode([GetEventRideDTO].self, from: data)
                
                // Sicherstellen, dass die Updates im Main-Thread ausgeführt werden
                DispatchQueue.main.async {
                    self?.eventRides = []
                    self?.eventRides = decodedEventRides // Array mit den Sonderfahrten speichern
                }
            } catch {
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // Gruppierung der Daten (Event oder Ride) nach Monat und Jahr
    var groupedData: [Dictionary<String, [Any]>.Element] {
        let filtered = filteredData
        print(filtered)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM - yyyy"  // Format: "Januar - 2025"
        
        var grouped: [String: [Any]] = [:]
        
        // Gruppierung nach Monat und Jahr
        for item in filtered {
            if let event = item as? GetEventDTO {
                let key = dateFormatter.string(from: event.starts)
                grouped[key, default: []].append(event)
            } else if let ride = item as? GetSpecialRideDTO {
                let key = dateFormatter.string(from: ride.starts)
                grouped[key, default: []].append(ride)
            } else if let eventRide = item as? GetEventRideDTO {
                let key = dateFormatter.string(from: eventRide.starts)
                grouped[key, default: []].append(eventRide)
            }
        }
        
        // Sortierung innerhalb der Gruppen
        for (key, items) in grouped {
            grouped[key] = items.sorted { lhs, rhs in
                if let eventL = lhs as? GetEventDTO, let eventR = rhs as? GetEventDTO {
                    return eventL.starts < eventR.starts
                }
                if let rideL = lhs as? GetSpecialRideDTO, let rideR = rhs as? GetSpecialRideDTO {
                    return rideL.starts < rideR.starts
                }
                if let eventRideL = lhs as? GetEventRideDTO, let eventRideR = rhs as? GetEventRideDTO {
                    return eventRideL.starts < eventRideR.starts
                }
                if let eventL = lhs as? GetEventDTO, let eventRideR = rhs as? GetEventRideDTO {
                    return eventL.starts < eventRideR.starts
                }
                if let rideL = lhs as? GetSpecialRideDTO, let eventRideR = rhs as? GetEventRideDTO {
                    return rideL.starts < eventRideR.starts
                }
                if let eventRideL = lhs as? GetEventRideDTO, let eventR = rhs as? GetEventDTO {
                    return eventRideL.starts < eventR.starts
                }
                if let eventRideL = lhs as? GetEventRideDTO, let rideR = rhs as? GetSpecialRideDTO {
                    return eventRideL.starts < rideR.starts
                }
                return false
            }
        }
        
        // Sortierung der Gruppen nach Monat/Jahr
        return grouped.sorted { lhs, rhs in
            guard let lhsDate = dateFormatter.date(from: lhs.key),
                  let rhsDate = dateFormatter.date(from: rhs.key) else {
                return lhs.key < rhs.key
            }
            return lhsDate < rhsDate
        }
    }

    var filteredData: [Any] {
        switch selectedTab {
        case 0:
            return events
        case 1:
            return rides
        case 2:
            let filteredRides = rides.filter { $0.myState != .nothing }
            let filteredEventRides = eventRides.filter { $0.myState != .nothing }
            return filteredRides + filteredEventRides
        default:
            return []
        }
    }

}
