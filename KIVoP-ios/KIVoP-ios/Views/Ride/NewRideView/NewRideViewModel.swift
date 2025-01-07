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

    func saveRide() {
        if selectedOption == "EventFahrt" {
            print("EventID: \(eventId)")
            print("Empty Seats: \(emptySeats ?? 0)")
            print("Beschreibung: \(rideDescription)")
            print("Fahrzeug Beschreibung: \(vehicleDescription)")
            print("Startkoordinaten: \(latitude) + \(longitude)")
            print("Startzeit: \(starts)")
            print("Event Fahrt gespeichert")
        } else if selectedOption == "SonderFahrt"{
            print("Name: \(rideName)")
            print("Beschreibung: \(rideDescription)")
            print("Startzeit: \(starts)")
            print("Startkoordinaten: \(latitude) + \(longitude)")
            print("Zielkoordinaten: \(dstLatitude) + \(dstLongitude)")
            print("Fahrzeug Beschreibung: \(vehicleDescription)")
            print("Empty Seats: \(emptySeats ?? 0)")
            print("Sonderfahrt gespeichert")
        } else {
            print("Es konnte nicht gespeichert werden.")
        }
        
    }
}
