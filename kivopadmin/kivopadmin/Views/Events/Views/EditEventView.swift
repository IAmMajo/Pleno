import SwiftUI
import PosterServiceDTOs
import PhotosUI
import MapKit
import RideServiceDTOs

struct EditEventView: View {
    @State var eventDetail: GetEventDetailDTO // Lokale Kopie des Events
    var eventId: UUID
    
    // Vorbereitung: Koordinaten zu Adresse
    @State private var address: String = "Adresse wird geladen..."
    private let geocoder = CLGeocoder()
    
    @Environment(\.dismiss) var dismiss
    
    // Parameter zum Ändern des Events
    @State private var title: String = ""
    @State private var description: String = ""
    @State var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.6542, longitude: 7.3556), // Datteln
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var startDate = Date() // Startdatum
    @State private var endDate = Date()   // Enddatum
    
    // ViewModels
    @StateObject private var locationManager = LocationManager() // LocationManager: Benötigt um gespeicherte Orte zu laden
    @EnvironmentObject private var eventViewModel: EventViewModel // Event-ViewModel: Interaktionen mit dem Server

    var body: some View {
        NavigationStack {
            // Formular, um das Event zu bearbeiten
            editEventForm
            
            .navigationTitle("Event \(eventDetail.name) bearbeiten")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {}
            }
        }
        .onAppear {
            locationManager.fetchLocations()
            
            // Bei View-Aufruf werden die Variablen mit den bestehenden Werten des Events befüllt
            title = eventDetail.name
            description = eventDetail.description ?? ""
            startDate = eventDetail.starts
            endDate = eventDetail.ends
            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: Double(eventDetail.latitude), longitude: Double(eventDetail.longitude)),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            
            
        }
    }

    // Event speichern
    private func saveEvent() {
        guard !title.isEmpty else {
            print("Titel ist erforderlich")
            return
        }

        let latitude = Float(mapRegion.center.latitude)
        let longitude = Float(mapRegion.center.longitude)

        let patchEvent = PatchEventDTO(
            name: title,
            description: description,
            starts: startDate,
            ends: endDate,
            latitude: latitude,
            longitude: longitude
        )

        eventViewModel.patchEvent(event: patchEvent, eventId: eventId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            eventViewModel.fetchEventDetail(eventId: eventId)
        }
        dismiss()
    }


    // Koordinaten in Adresse übersetzen
    private func updateAddress(for coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Fehler bei der Umkehr-Geokodierung: \(error.localizedDescription)")
                address = "Adresse konnte nicht geladen werden"
                return
            }
            
            if let placemark = placemarks?.first {
                address = [
                    placemark.name,          // Straßenname oder Ort
                    placemark.locality,      // Stadt
                    placemark.administrativeArea, // Bundesland
                    placemark.country        // Land
                ]
                .compactMap { $0 }          // Entfernt nil-Werte
                .joined(separator: ", ")   // Verbindet die Teile der Adresse
            } else {
                address = "Keine Adresse gefunden"
            }
        }
    }
}

extension EditEventView {
    var editEventForm: some View {
        // Formular, um Event zu bearbeiten
        Form {
            Section(header: Text("Allgemeine Informationen")) {
                TextField("Titel", text: $title)
                TextField("Beschreibung", text: $description)
            }
            
            Section(header: Text("Datum und Uhrzeit")) {
                DatePicker("Startdatum", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                DatePicker("Enddatum", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
            }

            Section(header: Text("Location Details")) {
                VStack(alignment: .leading) {
                    NavigationLink(destination: SelectPlaceView(mapRegion: $mapRegion)) {
                        Text(address) // Zeigt die Adresse an
                    }
                    .onAppear {
                        updateAddress(for: mapRegion.center)
                    }
                }
            }

            // Button, um Event zu speichern
            Button(action: saveEvent) {
                Text("Speichern")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
    }
}
