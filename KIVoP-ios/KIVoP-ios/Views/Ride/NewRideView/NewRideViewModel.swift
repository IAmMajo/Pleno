//
//  NewRideViewModel.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 06.01.25.
//

import SwiftUI
import RideServiceDTOs

class NewRideViewModel: ObservableObject {
    @Published var selectedOption: String?
    
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
        print("Name: \(rideName)")
        print("Beschreibung: \(rideDescription)")
        print("Startzeit: \(starts)")
        print("Startkoordinaten: \(latitude) + \(longitude)")
        print("Zielkoordinaten: \(dstLatitude) + \(dstLongitude)")
        print("Fahrzeug Beschreibung: \(vehicleDescription)")
        print("Empty Seats: \(emptySeats ?? 0)")
        print("Sonderfahrt gespeichert")
    }
}

// Alert Switch fürs Speichern
enum ActiveAlert {
    case save, error
}
