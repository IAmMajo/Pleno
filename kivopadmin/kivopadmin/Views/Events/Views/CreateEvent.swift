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



import SwiftUI
import PosterServiceDTOs
import PhotosUI
import MapKit
import RideServiceDTOs

struct EventErstellenView: View {
    @State private var address: String = "Adresse wird geladen..."
    private let geocoder = CLGeocoder()
    @Environment(\.dismiss) var dismiss
    
    // Variablen für neues Event
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
    @State private var startDate = Date() // Startdatum
    @State private var endDate = Date()   // Enddatum
    
    // Startwert für die Map
    // Hier: Start in Datteln
    @State var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.6542, longitude: 7.3556),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    // ViewModels
    @StateObject private var locationManager = LocationManager() // LocationManager: Benötigt um gespeicherte Orte zu laden
    @EnvironmentObject private var eventViewModel: EventViewModel // Event-ViewModel für alle Interaktionen mit dem Server

    var body: some View {
        NavigationStack {
            // Formular, um Event zu erstellen
            createEventForm
            .navigationTitle("Event erstellen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Alle gespeicherten Orte fetchen
            locationManager.fetchLocations()
        }
    }

    // Event speichern
    private func saveEvent() {
        
        // Titel ist erforderlich
        guard !title.isEmpty else {
            print("Titel ist erforderlich")
            return
        }

        // Koordinaten auslesen
        let latitude = Float(mapRegion.center.latitude)
        let longitude = Float(mapRegion.center.longitude)

        // CreateEventDTO erzeugen
        let newEvent = CreateEventDTO(
            name: title,
            description: description,
            starts: startDate,
            ends: endDate,
            latitude: latitude,
            longitude: longitude
        )
        
        // Event erstellen
        eventViewModel.createEvent(event: newEvent)
        
        // Eine Sekunde warten, damit das Event im Backend angelegt werden kann
        // Dann können alle Events gefetcht werden
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            eventViewModel.fetchEvents()
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

extension EventErstellenView{
    
    // Formular zum erstellen des Events
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

            // Event speichern
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
