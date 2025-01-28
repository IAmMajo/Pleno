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
    @Published var events: [EventWithAggregatedData] = []
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
                DispatchQueue.main.async {
                    self?.fetchEventRides {
                        // Berechne und füge die aggregierten Daten hinzu
                        self?.events = decodedEvents.map { event in
                            let aggregatedData = self?.aggregatedData(for: event) ?? (.nothing, 0, 0, nil)
                            return EventWithAggregatedData(event: event, allOpenRequests: aggregatedData.allOpenRequests, allAllocatedSeats: aggregatedData.allAllocatedSeats, allEmptySeats: aggregatedData.allEmptySeats, myState: aggregatedData.myState)
                        }
                    }
                }
            } catch {
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // Fetch alle EventRides für die Auswahl im Array
    func fetchEventRides(completion: @escaping () -> Void) {
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
                DispatchQueue.main.async {
                    self?.eventRides = []
                    self?.eventRides = decodedEventRides
                    completion()
                }
            } catch {
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // Gruppierung der Daten (Event oder Ride) nach Monat und Jahr
    var groupedData: [Dictionary<String, [Any]>.Element] {
        let filtered = filteredData
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM - yyyy"  // Format: "Januar - 2025"
        
        var grouped: [String: [Any]] = [:]
        
        // Gruppierung nach Monat und Jahr
        for item in filtered {
            if let event = item as? EventWithAggregatedData {
                let key = dateFormatter.string(from: event.event.starts)
                grouped[key, default: []].append(event)
            } else if let ride = item as? GetSpecialRideDTO {
                let key = dateFormatter.string(from: ride.starts)
                grouped[key, default: []].append(ride)
            } else if let eventRide = item as? GetEventRideDTO {
                let key = dateFormatter.string(from: eventRide.starts)
                grouped[key, default: []].append(eventRide)
            } else {
                print("Unrecognized item type: \(item)")
            }
        }
        
        // Sortierung innerhalb der Gruppen
        for (key, items) in grouped {
            grouped[key] = items.sorted { lhs, rhs in
                if let eventL = lhs as? EventWithAggregatedData, let eventR = rhs as? EventWithAggregatedData {
                    return eventL.event.starts < eventR.event.starts
                }
                if let rideL = lhs as? GetSpecialRideDTO, let rideR = rhs as? GetSpecialRideDTO {
                    return rideL.starts < rideR.starts
                }
                if let eventRideL = lhs as? GetEventRideDTO, let eventRideR = rhs as? GetEventRideDTO {
                    return eventRideL.starts < eventRideR.starts
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
    
    // Berechnung der aggregierten Daten
    func aggregatedData(for event: GetEventDTO) -> (myState: UsersRideState, allEmptySeats: UInt8, allAllocatedSeats: UInt8, allOpenRequests: UInt8?) {
        let relevantEventRides = eventRides.filter { $0.eventID == event.id }
        
        let allEmptySeats = relevantEventRides.reduce(0) { $0 + $1.emptySeats }
        let allAllocatedSeats = relevantEventRides.reduce(0) { $0 + $1.allocatedSeats }
        
        let allOpenRequests = relevantEventRides.reduce(0) { $0 + ($1.openRequests ?? 0) }
        let allOpenRequestsUInt8: UInt8? = allOpenRequests > 0 ? UInt8(allOpenRequests) : nil
        
        let myState: UsersRideState
        if relevantEventRides.contains(where: { $0.myState == .driver }) {
            myState = .driver
        } else if relevantEventRides.contains(where: { $0.myState == .accepted }) {
            myState = .accepted
        } else if relevantEventRides.contains(where: { $0.myState == .requested }) {
            myState = .requested
        } else {
            myState = .nothing
        }
        return (myState, allEmptySeats, allAllocatedSeats, allOpenRequestsUInt8)
    }
}

struct EventWithAggregatedData {
    var event: GetEventDTO
    var allOpenRequests: UInt8?
    var allAllocatedSeats: UInt8
    var allEmptySeats: UInt8
    var myState: UsersRideState
}
