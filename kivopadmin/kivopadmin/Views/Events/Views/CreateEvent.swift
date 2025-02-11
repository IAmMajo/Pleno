import SwiftUI
import PosterServiceDTOs
import PhotosUI
import MapKit
import RideServiceDTOs

struct EventErstellenView: View {
    @State private var address: String = "Adresse wird geladen..."
    private let geocoder = CLGeocoder()
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil // Optional Data für das Bild
    @State private var locationName: String = ""
    @State private var locationStreet: String = ""
    @State private var locationNumber: String = ""
    @State private var locationLetter: String = ""
    @State private var locationPostalCode: String = ""
    @State private var locationPlace: String = ""
    @State private var isAddingNewLocation = false
    @State private var selectedLocationID: UUID?
    @State var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.6542, longitude: 7.3556),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var startDate = Date() // Startdatum
    @State private var endDate = Date()   // Enddatum
    
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject private var eventViewModel: EventViewModel

    var body: some View {
        NavigationStack {
            // Formular, um Event zu erstellen
            createEventForm
            .navigationTitle("Event erstellen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {}
            }
        }
        .onAppear {
            locationManager.fetchLocations()
        }
    }

    private func saveEvent() {
        guard !title.isEmpty else {
            print("Titel ist erforderlich")
            return
        }

        let latitude = Float(mapRegion.center.latitude)
        let longitude = Float(mapRegion.center.longitude)

        let newEvent = CreateEventDTO(
            name: title,
            description: description,
            starts: startDate,
            ends: endDate,
            latitude: latitude,
            longitude: longitude
        )
        
        eventViewModel.createEvent(event: newEvent)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            eventViewModel.fetchEvents()
        }
        dismiss()
    }

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

extension EventErstellenView{
    private var createEventForm: some View {
        Form {
            Section(header: Text("Allgemeine Informationen")) {
                TextField("Titel", text: $title)
                TextField("Beschreibung", text: $description)
            }
            
            Section(header: Text("Datum und Uhrzeit")) {
                DatePicker("Startdatum", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                DatePicker("Enddatum", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
            }

            Section(header: Text("Adresse auswählen")) {
                VStack(alignment: .leading) {
                    NavigationLink(destination: SelectPlaceView(mapRegion: $mapRegion)) {
                        Text(address) // Zeigt die Adresse an
                    }
                    .onAppear {
                        updateAddress(for: mapRegion.center)
                    }
                }
            }

            Button(action: saveEvent) {
                Text("Event erstellen")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
    }
}
