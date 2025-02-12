// This file is licensed under the MIT-0 License.
import Foundation
import CoreLocation
import MapKit
import RideServiceDTOs

@MainActor
class EventRideDetailViewModel: ObservableObject {
    @Published var eventRide: GetEventRideDTO
    @Published var eventRideDetail: GetEventRideDetailDTO
    @Published var eventDetails: GetEventDetailDTO
    @Published var requestedRiders: [GetRiderDTO] = []
    @Published var acceptedRiders: [GetRiderDTO] = []
    @Published var alreadyAccepted: String = "" // Wenn myState .accepted oder .driver bei einem EventRide von dem Event, dann kann man keinen Request stellen
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showDeleteRideAlert: Bool = false // Fahrer der seine Fahrt löschen will
    @Published var showPassengerDeleteRequest: Bool = false // Fahrer löscht einen Mitfahrer im nachhinein
    @Published var showPassengerAddRequest: Bool = false // Fahrer akzeptiert einen Request
    @Published var showDeleteRideRequest: Bool = false // Wenn ein Mitfahrer seinen Request zurücknehmen will
    @Published var showRiderDeleteRequest: Bool = false // Wenn ein Mitfahrer seine Fahrt löschen will
    @Published var driverAddress: String = ""
    @Published var riderAddresses: [UUID: String] = [:] // Um die Adressen für die Mitfahrer zu berechnen, dabei wird eine Map verwendet, um auch mehrere Adressen gut berechnen zu können
    @Published var eventAddress: String = ""
    @Published var eventLocation: CLLocationCoordinate2D?
    @Published var driverLocation: CLLocationCoordinate2D?
    
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
    
    @Published var rideManager = RideManager.shared
    
    var rider: GetRiderDTO?
    
    init(eventRide: GetEventRideDTO) {
        self.eventRide = eventRide
        // leeres Objekt erstellen, um Fehler zu vermeiden
        self.eventDetails = GetEventDetailDTO(
            id: UUID(),
            name: "",
            starts: Date(),
            ends: Date(),
            latitude: 0,
            longitude: 0,
            participations: [],
            userWithoutFeedback: [],
            countRideInterested: 0,
            countEmptySeats: 0
        )
        // leeres Objekt erstellen, um Fehler zu vermeiden
        self.eventRideDetail = GetEventRideDetailDTO(
            id: UUID(),
            eventID: UUID(),
            eventName: "",
            driverName: "",
            driverID: UUID(),
            isSelfDriver: false,
            starts: Date(),
            latitude: 0,
            longitude: 0,
            emptySeats: 0,
            riders: []
        )
    }
    
    // Updateing all needed Values
    func fetchAllUpdates() {
        fetchEventRideDetails()
        fetchEventDetails()
        fetchEventRides()
    }
    
    // Event Details über den RideManager abfragen
    func fetchEventDetails() {
        Task {
            do {
                self.isLoading = true

                let fetchedDetails = try await rideManager.fetchEventDetails(eventID: eventRide.eventID)
                
                DispatchQueue.main.async {
                    self.eventDetails = fetchedDetails
                    self.eventLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.eventDetails.latitude) , longitude: CLLocationDegrees(self.eventDetails.longitude))
                    
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Abrufen der Event-Details: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Details zur EventFahrt abfragen
    func fetchEventRideDetails() {
        Task {
            do {
                self.isLoading = true
                
                // Abruf der Details über den RideManager
                let details = try await rideManager.fetchEventRideDetails(eventRideID: eventRide.id)
                
                // UI-Updates im Hauptthread durchführen
                DispatchQueue.main.async {
                    self.eventRideDetail = details
                    // Aufteilen der Rider in akzeptierte und angeforderte
                    self.acceptedRiders = details.riders.filter { $0.accepted }
                    self.requestedRiders = details.riders.filter { !$0.accepted }
                    // Eigener Rider (falls vorhanden) ermitteln
                    self.rider = details.riders.first(where: { $0.itsMe })
                    // Setze die Position des Fahrers (Startposition)
                    self.driverLocation = CLLocationCoordinate2D(
                        latitude: CLLocationDegrees(details.latitude),
                        longitude: CLLocationDegrees(details.longitude)
                    )
                    // Für jeden Rider wird die Adresse ermittelt
                    for rider in details.riders {
                        self.rideManager.getAddressFromCoordinates(latitude: rider.latitude, longitude: rider.longitude) { address in
                            if let address = address {
                                self.riderAddresses[rider.id] = address
                            }
                        }
                    }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Abrufen der Event Ride Details: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Die Abfrage aller Eventrides ist notwendig um zu prüfen, ob der Nutzer schon bei einer Fahrt zu dem Event akzeptiert wurde
    func fetchEventRides() {
        Task {
            do {
                self.isLoading = true
                
                // Abruf der Event-Fahrten über den RideManager
                let eventRides = try await rideManager.fetchEventRidesByEvent(eventID: eventRide.eventID)
                
                DispatchQueue.main.async {
                    // Überprüfe, ob ein Ride mit myState .driver existiert
                    if let _ = eventRides.first(where: { $0.myState == .driver }) {
                        self.alreadyAccepted = "driver"
                    } else if let _ = eventRides.first(where: { $0.myState == .accepted }) {
                        self.alreadyAccepted = "accepted"
                    }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                print("Fehler beim Abrufen der Event-Fahrten: \(error.localizedDescription)")
            }
        }
    }
    
    // Fahrer löscht die Fahrt
    func deleteRide() {
        Task {
            do {
                self.isLoading = true
                // Aufruf der deleteRide-Methode im RideManager
                try await rideManager.deleteRide(rideID: eventRide.id)
                
                DispatchQueue.main.async {
                    // Erfolgreiches Löschen: Entferne den eigenen Rider aus der Liste
                    if let index = self.requestedRiders.firstIndex(where: { $0.itsMe }) {
                        self.requestedRiders.remove(at: index)
                    }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Löschen der Fahrt: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Mitfahrer fragt einen Sitzplatz an
    func requestEventRide() {
        Task {
            do {
                self.isLoading = true
                
                // Aufruf der asynchronen Methode im RideManager
                let fetchedRider = try await rideManager.requestEventRide(eventRideID: eventRide.id)
                
                // UI-Updates im Hauptthread durchführen
                DispatchQueue.main.async {
                    self.requestedRiders.append(fetchedRider)
                    self.rider = fetchedRider
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Anfordern der Fahrt: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Fahrer akzeptiert einen Request
    func acceptRequestedRider(rider: GetRiderDTO) {
        Task {
            do {
                self.isLoading = true
                
                // API-Aufruf über den RideManager
                let updatedRider = try await rideManager.acceptRequestedRider(riderID: rider.id)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    // Aktualisiere die Listen: Entferne den Rider aus den angefragten und füge ihn den akzeptierten hinzu
                    if let index = self.requestedRiders.firstIndex(where: { $0.id == rider.id }) {
                        self.acceptedRiders.append(updatedRider)
                        self.requestedRiders.remove(at: index)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Akzeptieren des angefragten Mitfahrers: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Fahrer entfernt einen Mitfahrer
    func removeFromPassengers(rider: GetRiderDTO) {
        Task {
            do {
                self.isLoading = true
                
                // API-Aufruf: Mitfahrer zurücksetzen (accepted = false)
                let updatedRider = try await rideManager.removeFromPassengers(riderID: rider.id)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    // Aus der Liste der akzeptierten Mitfahrer entfernen und in die Liste der angefragten Mitfahrer einfügen
                    if let index = self.acceptedRiders.firstIndex(where: { $0.id == rider.id }) {
                        self.acceptedRiders.remove(at: index)
                        self.requestedRiders.append(updatedRider)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Entfernen des Mitfahrers: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Löschen der Anfrage durch den Mitfahrer
    func deleteRideRequestedSeat(rider: GetRiderDTO) {
        Task {
            do {
                self.isLoading = true
                
                // Aufruf der asynchronen Methode im RideManager
                try await rideManager.deleteRideRequestedSeat(riderID: rider.id)
                
                // UI-Updates im Hauptthread durchführen
                DispatchQueue.main.async {
                    // Entferne den Mitfahrer aus beiden Listen
                    self.requestedRiders.removeAll { $0.id == rider.id }
                    self.acceptedRiders.removeAll { $0.id == rider.id }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Löschen der Anfrage: \(error.localizedDescription)")
                }
            }
        }
    }
}
