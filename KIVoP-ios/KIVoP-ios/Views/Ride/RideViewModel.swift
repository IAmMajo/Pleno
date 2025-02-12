// This file is licensed under the MIT-0 License.
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
    
    @Published var rideManager = RideManager.shared
    
    // Funktion um alle Inhalte für die Übersicht (RideView) abzurufen
    func fetchRides(){
        fetchSpecialRides()
        fetchEvents()
        fetchEventRides()
    }
    
    // SpecialRides über den RideManager abfragen
    func fetchSpecialRides() {
        isLoading = true
        rideManager.fetchSpecialRides { [weak self] fetchedRides in
            DispatchQueue.main.async {
                if let fetchedRides = fetchedRides {
                    self?.rides = fetchedRides  // Set the fetched rides
                } else {
                    self?.errorMessage = "Failed to load special rides."
                }
                self?.isLoading = false  // Hide loading indicator
            }
        }
    }
    
    // Fetch Events für die Auswahl im Array
    func fetchEvents() {
        isLoading = true
        rideManager.fetchEvents { [weak self] fetchedEvents in
            DispatchQueue.main.async {
                if let fetchedEvents = fetchedEvents {
                    self?.events = fetchedEvents  // Setze die Events
                } else {
                    self?.errorMessage = "Failed to load events."
                }
                self?.isLoading = false  // Ladeanzeige ausschalten
            }
        }
    }
    
    // Fetch alle EventRides für die Auswahl im Array
    func fetchEventRides() {
        isLoading = true
        rideManager.fetchEventRides { [weak self] fetchedEventRides in
            DispatchQueue.main.async {
                if let fetchedEventRides = fetchedEventRides {
                    self?.eventRides = fetchedEventRides  // Set the eventRides if fetched successfully
                } else {
                    self?.errorMessage = "Failed to load event rides."
                }
                self?.isLoading = false  // Hide loading indicator
            }
        }
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

    // Inhalte anhand vom ausgewählten Tab Filtern
    // Tab 1 Events
    // Tab 2 Sonderfahrten (bei denen noch Platz ist)
    // Tab 3 Fahrten zu Events und Sonderfahrten (Mit denen der Nutezr interagiert hat)
    var filteredData: [Any] {
        switch selectedTab {
        case 0:
            return events
        case 1:
            return rides.filter { $0.emptySeats - $0.allocatedSeats > 0 }
        case 2:
            let filteredRides = rides.filter { $0.myState != .nothing }
            let filteredEventRides = eventRides.filter { $0.myState != .nothing }
            return filteredRides + filteredEventRides
        default:
            return []
        }
    }
}

// Event mit modifizierten Daten
struct EventWithAggregatedData {
    var event: GetEventDTO
    var allOpenRequests: UInt8?
    var allAllocatedSeats: UInt8
    var allEmptySeats: UInt8
    var myState: UsersRideState
}
