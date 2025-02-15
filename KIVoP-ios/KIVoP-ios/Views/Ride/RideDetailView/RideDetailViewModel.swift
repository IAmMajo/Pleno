// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import CoreLocation
import MapKit
import RideServiceDTOs

// MainActor um Änderung auf dem Hauptthread durchzuführen
@MainActor
class RideDetailViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedOption: String // Für EventDetails anpassen
    @Published var rideDetail: GetSpecialRideDetailDTO
    @Published var requestedRiders: [GetRiderDTO] = []
    @Published var acceptedRiders: [GetRiderDTO] = []
    
    @Published var showDeleteRideAlert: Bool = false // Fahrer der seine Fahrt löschen will
    @Published var showPassengerDeleteRequest: Bool = false // Fahrer löscht einen Mitfahrer im nachhinein
    @Published var showPassengerAddRequest: Bool = false // Fahrer akzeptiert einen Request
    @Published var showDeleteRideRequest: Bool = false // Wenn ein Mitfahrer seinen Request zurücknehmen will
    @Published var showRiderDeleteRequest: Bool = false // Wenn ein Mitfahrer seine Fahrt löschen will
    @Published var showLocationRequest: Bool = false // sheet um die Location festzulegen vor einer Anfrage
    
    @Published var requestLat: Float = 0
    @Published var requestLong: Float = 0
    @Published var driverAddress: String = ""
    @Published var requestedAdress: String = "" // Adresse für die Anzeige beim Auswählen der Location für einen Mitfahrer
    @Published var riderAddresses: [UUID: String] = [:] // Um die Adressen für die Mitfahrer zu berechnen
    @Published var destinationAddress: String = ""
    @Published var location: CLLocationCoordinate2D?
    @Published var requestedLocation: CLLocationCoordinate2D? // Location für die Anfrage
    @Published var startLocation: CLLocationCoordinate2D?
    @Published var shouldShowDriversProfilePicture = false // Variable um das Profilbild des Fahrers etwas später zu laden
    
    @Published var rideManager = RideManager.shared
    
    // Vars um Standort zu kopieren
    @Published var shareLocation = false
    @Published var isGoogleMapsInstalled = false
    @Published var isWazeInstalled = false
    @Published var showMapOptions: Bool = false
    @Published var setKoords: CLLocationCoordinate2D?
    @Published var setAddress: String?
    func formattedShareText() -> String {
       """
       \(setAddress ?? "")
       """
    }
    
    var ride: GetSpecialRideDTO
    var rider: GetRiderDTO?
    
    init(ride: GetSpecialRideDTO) {
        self.ride = ride
        self.selectedOption = "SonderFahrt"
        self.rideDetail = GetSpecialRideDetailDTO(
            id: UUID(),
            driverName: "",
            driverID: UUID(),
            isSelfDriver: false,
            name: "",
            description: nil,
            vehicleDescription: nil,
            starts: Date(),
            ends: Date(),
            startLatitude: 0.0,
            startLongitude: 0.0,
            destinationLatitude: 0.0,
            destinationLongitude: 0.0,
            emptySeats: 0,
            riders: []
        )
    }
    
    // Details zu der Fahrt im RideManager abfragen
    // Außerdem alle benötigten Variablen setzen
    func fetchRideDetails() {
        Task {
            do {
                self.isLoading = true
                let fetchedRideDetail = try await rideManager.fetchRideDetails(for: ride.id)

                DispatchQueue.main.async {
                    self.rideDetail = fetchedRideDetail
                    self.groupRiders()
                    self.rider = self.rideDetail.riders.first(where: { $0.itsMe })
                    self.isLoading = false
                    self.location = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.rideDetail.destinationLatitude) , longitude: CLLocationDegrees(self.rideDetail.destinationLongitude) )
                    self.startLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.rideDetail.startLatitude), longitude: CLLocationDegrees(self.rideDetail.startLongitude))
                    // Durchlaufe alle Fahrer und rufe die Adresse für jedes Fahrer-Standort ab
                    for rider in self.rideDetail.riders {
                        self.rideManager.getAddressFromCoordinates(latitude: rider.latitude, longitude: rider.longitude) { address in
                            if let address = address {
                                // Speichere die Adresse im Dictionary mit der Rider ID als Schlüssel
                                self.riderAddresses[rider.id] = address
                            }
                        }
                    }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    print("Fehler beim Abrufen der Ride Details: \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        }
    }
    
    // Fahrer löscht die Fahrt
    func deleteRide() {
        Task {
            do {
                self.isLoading = true
                // Löschanfrage an den RideManager
                try await rideManager.deleteSpecialRide(rideID: ride.id)
                self.isLoading = false
                
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Fehler beim Löschen der Fahrt: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Mitfahrer fragt einen Platz an
    func requestRide() {
        Task {
            do {
                self.isLoading = true

                // Anforderung der Fahrt über den RideManager
                let fetchedRider = try await rideManager.requestSpecialRide(rideID: ride.id, latitude: requestLat, longitude: requestLong)

                DispatchQueue.main.async {
                    // Füge den Rider zur Liste der angeforderten Fahrer hinzu
                    self.requestedRiders.append(fetchedRider)
                    self.rider = fetchedRider
                    self.isLoading = false
                }

            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Fehler beim Anfordern der Fahrt: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Löschen der Anfrage durch den Mitfahrer
    func deleteRideRequestedSeat(rider: GetRiderDTO) {
        Task {
            do {
                self.isLoading = true

                // Lösche die Anfrage über den RideManager
                try await rideManager.deleteSpecialRideRequestedSeat(riderID: rider.id)

                DispatchQueue.main.async {
                    // Erfolgreiches Löschen: Entferne den Rider aus den Listen
                    self.requestedRiders.removeAll { $0.id == rider.id }
                    self.acceptedRiders.removeAll { $0.id == rider.id }
                    self.isLoading = false
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Fehler beim Löschen der Anfrage: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Fahrer akzeptiert einen Request
    func acceptRequestedRider(rider: GetRiderDTO) {
        Task {
            do {
                self.isLoading = true  // Ladezustand aktivieren

                // Akzeptiere den angefragten Mitfahrer durch den RideManager
                let updatedRider = try await rideManager.acceptRequestedSpecialRider(riderID: rider.id, longitude: rider.longitude, latitude: rider.latitude)

                DispatchQueue.main.async {
                    // Ladezustand deaktivieren
                    self.isLoading = false
                    
                    // Rider aus der Liste der angeforderten Mitfahrer entfernen und zu den akzeptierten Mitfahrern hinzufügen
                    if let index = self.requestedRiders.firstIndex(where: { $0.id == rider.id }) {
                        self.acceptedRiders.append(updatedRider)
                        self.requestedRiders.remove(at: index)
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false  // Ladezustand deaktivieren
                    self.errorMessage = "Fehler beim Akzeptieren des Mitfahrers: \(error.localizedDescription)"
                }
            }
        }
    }

    // Fahrer entfernt den Mitfahrer wieder - Dieser ist wieder requested
    func removeFromPassengers(rider: GetRiderDTO) {
        Task {
            do {
                self.isLoading = true  // Ladezustand aktivieren

                // Entferne den Mitfahrer und setze ihn auf "requested"
                let updatedRider = try await rideManager.removeFromSpecialPassengers(riderID: rider.id, longitude: rider.longitude, latitude: rider.latitude)

                DispatchQueue.main.async {
                    // Ladezustand deaktivieren
                    self.isLoading = false
                    
                    // Rider aus der Liste der akzeptierten Mitfahrer entfernen und zu den angeforderten Mitfahrern hinzufügen
                    if let index = self.acceptedRiders.firstIndex(where: { $0.id == rider.id }) {
                        self.acceptedRiders.remove(at: index)
                        self.requestedRiders.append(updatedRider)
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false  // Ladezustand deaktivieren
                    self.errorMessage = "Fehler beim Entfernen des Mitfahrers: \(error.localizedDescription)"
                }
            }
        }
    }

    // Nach dem RideDetails geholt wurden, werden die riders aufgeteilt
    func groupRiders(){
        // aufteilen in Gruppen für die View
        acceptedRiders = rideDetail.riders.filter { $0.accepted }
        requestedRiders = rideDetail.riders.filter { !$0.accepted }
    }
}
