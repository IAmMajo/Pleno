// This file is licensed under the MIT-0 License.
import Foundation
import CoreLocation
import RideServiceDTOs

// Generelles zu EventFahrten Logik
// Zuerst muss der Nutzer sein Interesse am Event melden
// Das geschieht in der Regel über die Event Ansicht
// Falls der Nutzer jedoch Fahrten zu einem Event sehen möchte, zu dem er noch nicht zu gestimmt hat, gibt es die Abkürzung sich direkt über die EventFahrt als Interessiert für das Event zu melden
// Das wird mit participateEvent() dargestellt
// Bevor der Nutzer einer Fahrgemeinschaft beitreten kann muss er noch sein Interesse bekunden mitgenommen zu werden
// Das wird mit requestInterestEventRide() abgebildet
// Damit signalisiert der Nutzer das er mitgenommen werden möchte und legt seinen Abholort fest

@MainActor
class EventRideViewModel: ObservableObject {
    @Published var event: GetEventDTO
    @Published var eventDetails: GetEventDetailDTO?
    @Published var eventRides: [GetEventRideDTO] = []
    @Published var interestedEvent: GetInterestedPartyDTO?
    @Published var editInterestEvent: Bool = false // To modify the LocationRequestView
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showLocationRequest: Bool = false // sheet um die Location festzulegen vor einer Anfrage
    @Published var requestLat: Float = 0
    @Published var requestLong: Float = 0
    @Published var requestedLocation: CLLocationCoordinate2D? // Location für die Anfrage
    @Published var requestedAdress: String = "" // Adresse für die Anzeige beim Auswählen der Location für einen Mitfahrer
    
    @Published var address: String = ""
    @Published var driverAddress: [UUID: String] = [:]
    
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
    
    init(event: GetEventDTO) {
        self.event = event
    }
    
    // Alle benötigten Daten werden aktualisiert
    func fetchAllUpadtes() {
        fetchEventDetails()
        fetchEventRides()
        fetchParticipation()
    }
    
    func fetchEventRides() {
        Task {
            do {
                self.isLoading = true
                
                let fetchedRides = try await rideManager.fetchEventRidesByEvent(eventID: event.id)
                
                DispatchQueue.main.async {
                    self.eventRides = fetchedRides
                    self.isLoading = false
                    
                    // Adressen für alle Fahrer abrufen
                    for ride in self.eventRides {
                        self.rideManager.getAddressFromCoordinates(latitude: ride.latitude, longitude: ride.longitude) { address in
                            if let address = address {
                                self.driverAddress[ride.driverID] = address
                            }
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Abrufen der Event-Fahrten: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchEventDetails() {
        Task {
            do {
                self.isLoading = true

                let fetchedDetails = try await rideManager.fetchEventDetails(eventID: event.id)

                DispatchQueue.main.async {
                    self.eventDetails = fetchedDetails
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
    
    // Prüfen ob es ein Objekt gibt, welches bestätigt, dass der Nutzer am Event teilnimmt oder nicht
    func fetchParticipation() {
        Task {
            do {
                self.isLoading = true

                let interestedParty = try await rideManager.fetchEventParticipation(eventID: event.id)

                DispatchQueue.main.async {
                    self.interestedEvent = interestedParty
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Abrufen der Teilnahmeinformationen: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // An Event teilnehmen
    func participateEvent() {
        isLoading = true
        
        Task {
            do {
                try await rideManager.participateEvent(eventID: event.id)
                
                DispatchQueue.main.async {
                    self.event.myState = .present
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    print("Fehler beim Teilnehmen am Event: \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        }
    }
    
    // Abholort erstellen
    func requestInterestEventRide() {
        isLoading = true
        
        Task {
            do {
                try await rideManager.requestInterestEventRide(
                    eventID: event.id,
                    latitude: requestLat,
                    longitude: requestLong
                )

                DispatchQueue.main.async {
                    print("Interesse erfolgreich gesendet")
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    print("Fehler beim Anfragen der Mitfahrt: \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        }
    }
    
    // Abholort für eine Mitfahrgelegenheit bearbeiten
    func patchInterestEventRide() {
        Task {
            do {
                self.isLoading = true

                try await rideManager.patchInterestEventRide(
                    eventID: interestedEvent!.id,
                    latitude: requestLat,
                    longitude: requestLong
                )

                DispatchQueue.main.async {
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Patchen des Abholortes: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Interesse zu einer Mitfahrtgelegenheit löschen
    func deleteInterestEventRide() {
        Task {
            do {
                self.isLoading = true

                try await rideManager.deleteInterestEventRide(eventID: interestedEvent!.id)

                DispatchQueue.main.async {
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Löschen des Interesses: \(error.localizedDescription)")
                }
            }
        }
    }
}
