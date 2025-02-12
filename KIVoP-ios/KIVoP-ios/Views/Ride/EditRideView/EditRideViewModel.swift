// This file is licensed under the MIT-0 License.
import SwiftUI
import RideServiceDTOs
import CoreLocation

// Dieses ViewModel dient der gesamten Bearbeitung und Erstellung von SpecialRides und EventRides
@MainActor
class EditRideViewModel: ObservableObject {
    
    @Published var ride: GetSpecialRideDTO = GetSpecialRideDTO(id: UUID(), name: "", starts: Date(), ends: Date(), emptySeats: 0, allocatedSeats: 0, myState: .nothing)
    
    // SpecialRide der Bearbeitet wird
    @Published var rideDetail: GetSpecialRideDetailDTO = GetSpecialRideDetailDTO(id: UUID(), driverName: "", driverID: UUID(), isSelfDriver: false, name: "", starts: Date(), ends: Date(), startLatitude: 0, startLongitude: 0, destinationLatitude: 0, destinationLongitude: 0, emptySeats: 0, riders: [])
    
    // EventRide der Bearbeitet wird
    @Published var eventRideDetail: GetEventRideDetailDTO = GetEventRideDetailDTO(id: UUID(), eventID: UUID(), eventName: "", driverName: "", driverID: UUID(), isSelfDriver: false, starts: Date(), latitude: 0, longitude: 0, emptySeats: 0, riders: [])
    
    
    @Published var showingLocation = false
    @Published var showingDstLocation = false
    @Published var selectedOption: String?
    @Published var isLoading: Bool = false
    @Published var isSaved: Bool = false
    @Published var address: String = ""
    @Published var dstAddress: String = ""
    
    // Für Events
    @Published var events: [GetEventDTO] = []
    @Published var eventDetails: GetEventDetailDTO?
    @Published var selectedEventId: UUID?
    @Published var eventRide: GetEventRideDTO?
    
    // Alert switches
    @Published var showSaveAlert: Bool = false
    @Published var showDismissAlert: Bool = false
    
    // New Ride Vars
    @Published var rideName: String = "" // Special
    @Published var rideDescription: String = "" // Event und Special
    @Published var starts: Date = Date() // Event und Special
    @Published var location: CLLocationCoordinate2D?
    @Published var dstLocation: CLLocationCoordinate2D?
    @Published var vehicleDescription: String = "" // Event und Special
    @Published var emptySeats: Int? = nil // Event und Special
    
    // RideManager als Sammlung von API-Aufrufen und anderen Ride-Funktionen
    @Published var rideManager = RideManager.shared
    
    // Fürs Bearbeiten wird entweder SpecialRide oder EventRide übergeben
    // Fürs Anlegen wird gar nichts übergeben, daher werden in den Fällen Standartwerte genutzt
    init(rideDetail: GetSpecialRideDetailDTO? = nil, eventRideDetail: GetEventRideDetailDTO? = nil){
        // Details für Sonderfahrt
        self.rideDetail = rideDetail ?? GetSpecialRideDetailDTO(id: UUID(), driverName: "", driverID: UUID(), isSelfDriver: false, name: "", starts: Date(), ends: Date(), startLatitude: 0, startLongitude: 0, destinationLatitude: 0, destinationLongitude: 0, emptySeats: 0, riders: [])
        
        // Details für Eventfahrt
        self.eventRideDetail = eventRideDetail ?? GetEventRideDetailDTO(id: UUID(), eventID: UUID(), eventName: "", driverName: "", driverID: UUID(), isSelfDriver: false, starts: Date(), latitude: 0, longitude: 0, emptySeats: 0, riders: [])
        
        // Startort für Sonderfahrt
        if self.rideDetail.startLatitude != 0 && self.rideDetail.startLongitude != 0 {
              self.location = CLLocationCoordinate2D(
                latitude: CLLocationDegrees(self.rideDetail.startLatitude),
                longitude: CLLocationDegrees(self.rideDetail.startLongitude)
              )
          }
        
        // Zielort für Sonderfahrt
        if self.rideDetail.destinationLatitude != 0 && self.rideDetail.destinationLongitude != 0 {
            self.dstLocation = CLLocationCoordinate2D(
                latitude: CLLocationDegrees(self.rideDetail.destinationLatitude),
                longitude: CLLocationDegrees(self.rideDetail.destinationLongitude)
            )
        }
        
        // Zielort Eventfahrt
        if self.eventRideDetail.latitude != 0 && self.eventRideDetail.longitude != 0 {
            self.location = CLLocationCoordinate2D(
                latitude: CLLocationDegrees(self.eventRideDetail.latitude),
                longitude: CLLocationDegrees(self.eventRideDetail.longitude)
            )
        }
    }
    
    // Validierung ob alle benötigten Daten angegeben wurden
    // Datum muss immer in der Zukunft sein, alles andere sind Pflichtfelder
    // Ausnahme: EventFahrten brauchen keinen Hinweis zur Fahrt
    var isFormValid: Bool {
        if selectedOption == "EventFahrt" {
            // Für Events
            return starts > Date() &&
            location != nil &&
            !vehicleDescription.isEmpty &&
            emptySeats != nil
        } else if selectedOption == "SonderFahrt" {
            // Für Sonderfahrten
            return !rideName.isEmpty &&
            !rideDescription.isEmpty &&
            starts > Date() &&
            location != nil &&
            dstLocation != nil &&
            !vehicleDescription.isEmpty &&
            emptySeats != nil
        }
        return true
    }
    
    // Diese Funktion wird ausgeführt um eine neue Fahrt anzulegen
    // Anhand der selectedOption kann entschieden werden ob es sich um eine EventFahrt handelt oder um eine SonderFahrt
    func saveRide() {
        if selectedOption == "EventFahrt" {
            saveEventRide()
        } else if selectedOption == "SonderFahrt"{
            saveSpecialRide()
        } else {
            print("Es konnte nicht gespeichert werden.")
        }
    }
    
    // Diese Funktion wird ausgeführt um eine bearbeitete Fahrt zu speichern
    // Anhand der selectedOption kann entschieden werden ob es sich um eine EventFahrt handelt oder um eine SonderFahrt
    func saveEditedRide() {
        if selectedOption == "EventFahrt" {
            saveEditedEventRide()
        } else if selectedOption == "SonderFahrt"{
            saveEditedSpecialRide()
        } else {
            print("Es konnte nicht gespeichert werden.")
        }
    }
    
    // Neue SonderFahrt anlegen
    // Die Daten aus der View werden in ein DTO übergeben, dieses DTO wird an die eigentliche Funktion weitergegeben
    func saveSpecialRide(){
        let specialRide = CreateSpecialRideDTO(
            name: rideName,
            description: rideDescription,
            vehicleDescription: vehicleDescription,
            starts: starts,
            ends: starts.addingTimeInterval(86400), // Endet nach 24 Stunden
            startLatitude: Float(location!.latitude),
            startLongitude: Float(location!.longitude),
            destinationLatitude: Float(dstLocation!.latitude),
            destinationLongitude: Float(dstLocation!.longitude),
            emptySeats: UInt8(emptySeats ?? 0)
        )
        // Fahrt erstellen
        createSpecialRide(specialRide)
    }
    
    // SonderFahrt bearbeiten
    // Die Daten aus der View werden in ein DTO übergeben, dieses DTO wird an die eigentliche Funktion weitergegeben
    func saveEditedSpecialRide(){
        let specialRide = PatchSpecialRideDTO(
            name: rideDetail.name,
            description: rideDetail.description,
            vehicleDescription: rideDetail.vehicleDescription,
            starts: rideDetail.starts,
            ends: rideDetail.starts.addingTimeInterval(86400), // Endet nach 24 Stunden
            startLatitude: Float(location!.latitude),
            startLongitude: Float(location!.longitude),
            destinationLatitude: Float(dstLocation!.latitude),
            destinationLongitude: Float(dstLocation!.longitude),
            emptySeats: rideDetail.emptySeats
        )
        // Fahrt speichern
        editSpecialRide(specialRide)
    }
    
    // Neue EventFahrt anlegen
    // Die Daten aus der View werden in ein DTO übergeben, dieses DTO wird an die eigentliche Funktion weitergegeben
    func saveEventRide(){
        let eventRide = CreateEventRideDTO(
            eventID: selectedEventId!,
            description: rideDescription,
            vehicleDescription: vehicleDescription,
            starts: starts,
            latitude: Float(location!.latitude),
            longitude: Float(location!.longitude),
            emptySeats: UInt8(emptySeats ?? 0)
        )
        // Fahrt erstellen
        createEventRide(eventRide)
    }
    
    // EventFahrt bearbeiten
    // Die Daten aus der View werden in ein DTO übergeben, dieses DTO wird an die eigentliche Funktion weitergegeben
    func saveEditedEventRide(){
        let eventRide = PatchEventRideDTO(
            description: eventRideDetail.description,
            vehicleDescription: eventRideDetail.vehicleDescription,
            starts: eventRideDetail.starts,
            latitude: Float(location!.latitude),
            longitude: Float(location!.longitude),
            emptySeats: eventRideDetail.emptySeats
        )
        // Fahrt speichern
        editEventRide(eventRide)
    }

    
    // Fetch Event Details für ein ausgewähltes Event um die Details im Create anzuzeigen
    func fetchEventDetails(eventID: UUID) {
        Task {
            do {
                self.isLoading = true
                
                // Abruf der Event-Details über den RideManager
                let details = try await rideManager.fetchEventDetails(eventID: eventID)
                
                // UI-Update im Hauptthread durchführen
                DispatchQueue.main.async {
                    self.eventDetails = details
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
    
    // Alle Event Fahrten bekommen
    // Zur Überprüfung ob der Nutzer bereits eine Fahrt zu dem Event anbietet
    func fetchEventRides() {
        guard let eventID = selectedEventId else {
            print("No event ID selected")
            return
        }

        Task {
            do {
                DispatchQueue.main.async {
                    self.isLoading = true
                }

                let rides = try await rideManager.fetchEventRidesByEvent(eventID: eventID)

                DispatchQueue.main.async {
                    self.eventRide = rides.first { $0.myState == .driver }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Abrufen der Event-Fahrten: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Erstellen einer Sonderfahrt
    func createSpecialRide(_ specialRideDTO: CreateSpecialRideDTO) {
        Task {
            do {
                self.isLoading = true
                
                // Sende die Anfrage über den RideManager
                let specialRideDetail = try await rideManager.createSpecialRide(specialRideDTO)
                
                // UI-Update im Hauptthread
                DispatchQueue.main.async {
                    self.ride.id = specialRideDetail.id
                    self.isSaved = true
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Erstellen der Sonderfahrt: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Bearbeiten einer Sonderfahrt
    func editSpecialRide(_ specialRideDTO: PatchSpecialRideDTO) {
        Task {
            do {
                self.isLoading = true
                
                // Aktualisierung der Fahrt über RideManager
                let updatedRide = try await rideManager.editSpecialRide(specialRideDTO, rideID: rideDetail.id)
                
                // UI-Update im Hauptthread durchführen
                DispatchQueue.main.async {
                    self.ride.id = updatedRide.id
                    self.isSaved = true
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Bearbeiten der Spezialfahrt: \(error.localizedDescription)")
                }
            }
        }
    }

    // Erstellen einer EventFahrt
    func createEventRide(_ eventRideDTO: CreateEventRideDTO) {
        Task {
            do {
                self.isLoading = true
                
                // Erstellt die Event-Fahrt über RideManager
                let newEventRide = try await rideManager.createEventRide(eventRideDTO)
                
                // UI-Update im Hauptthread
                DispatchQueue.main.async {
                    self.ride.id = newEventRide.id
                    self.isSaved = true
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Erstellen der Event-Fahrt: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // EventFahrt bearbeiten
    func editEventRide(_ eventRideDTO: PatchEventRideDTO) {
        Task {
            do {
                self.isLoading = true
                
                // Bearbeitet die Event-Fahrt über RideManager
                let updatedEventRide = try await rideManager.editEventRide(eventRideDTO, rideID: self.eventRideDetail.id)

                // UI-Update im Hauptthread
                DispatchQueue.main.async {
                    self.ride.id = updatedEventRide.id
                    self.isSaved = true
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Fehler beim Bearbeiten der Event-Fahrt: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func participateEvent(eventID: UUID) {
        Task {
            do {
                self.isLoading = true
                
                try await rideManager.participateEvent(eventID: eventID)
                
                DispatchQueue.main.async {
                    if let index = self.events.firstIndex(where: { $0.id == eventID }) {
                        self.events[index].myState = .present
                    }
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                print("Fehler bei der Event-Teilnahme: \(error.localizedDescription)")
            }
        }
    }
}

// Alert Switch fürs Speichern
enum ActiveAlert {
    case save, error, participate
}
