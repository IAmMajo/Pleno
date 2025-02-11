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
    
    private let baseURL = "https://kivop.ipv64.net"
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
                let fetchedRideDetail = try await RideManager.shared.fetchRideDetails(for: ride.id)

                DispatchQueue.main.async {
                    self.rideDetail = fetchedRideDetail
                    self.groupRiders()
                    self.rider = self.rideDetail.riders.first(where: { $0.itsMe })
                    self.isLoading = false
                    self.location = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.rideDetail.destinationLatitude) , longitude: CLLocationDegrees(self.rideDetail.destinationLongitude) )
                    self.startLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.rideDetail.startLatitude), longitude: CLLocationDegrees(self.rideDetail.startLongitude))
                    // Durchlaufe alle Fahrer und rufe die Adresse für jedes Fahrer-Standort ab
                    for rider in self.rideDetail.riders {
                        self.getAddressFromCoordinates(latitude: rider.latitude, longitude: rider.longitude) { address in
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
                try await RideManager.shared.deleteSpecialRide(rideID: ride.id)
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
                let fetchedRider = try await RideManager.shared.requestSpecialRide(rideID: ride.id, latitude: requestLat, longitude: requestLong)

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
                try await RideManager.shared.deleteSpecialRideRequestedSeat(riderID: rider.id)

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
                let updatedRider = try await RideManager.shared.acceptRequestedSpecialRider(riderID: rider.id, longitude: rider.longitude, latitude: rider.latitude)

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
                let updatedRider = try await RideManager.shared.removeFromSpecialPassengers(riderID: rider.id, longitude: rider.longitude, latitude: rider.latitude)

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
    
    func getAddressFromCoordinates(latitude: Float, longitude: Float, completion: @escaping (String?) -> Void) {
        let clLocation = CLLocation(latitude: Double(latitude), longitude: Double(longitude))
        
        CLGeocoder().reverseGeocodeLocation(clLocation) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?.first else {
                completion(nil)
                return
            }
            
            var addressString = ""
            if let name = placemark.name {
                addressString += name
            }
            if let postalCode = placemark.postalCode {
                addressString += ", \(postalCode)"
            }
            if let city = placemark.locality {
                addressString += " \(city)"
            }
            
            completion(addressString)
        }
    }

    // Nach dem RideDetails geholt wurden, werden die riders aufgeteilt
    func groupRiders(){
        // aufteilen in Gruppen für die View
        acceptedRiders = rideDetail.riders.filter { $0.accepted }
        requestedRiders = rideDetail.riders.filter { !$0.accepted }
    }
}
