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
import RideServiceDTOs
import MapKit

struct EventRideDetailView: View {
    
    // ViewModel als EnvironmentObject
    @EnvironmentObject private var rideViewModel: RideViewModel
    
    // ID der Fahrt wird beim View-Aufruf übergeben
    var rideId: UUID
    
    // Vorbereitungen, um Koordinaten in eine Adresse zu übersetzen
    private let geocoder = CLGeocoder()
    @State private var address: String = "Adresse wird geladen..."
    
    var body: some View {
        List {
            if let rideDetail = rideViewModel.eventRideDetail {
                // Details zur Event-Fahrt
                detailsSection(rideDetail: rideDetail)

                // Angaben zur Adresse
                placeSection(rideDetail: rideDetail)

                // Angaben zu Mitfahrern
                participationsSection(rideDetail: rideDetail)
            } else {
                Text("Lade Fahrtdetails...")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Fahrt-Details")
        .onAppear {
            // Bei View-Aufruf wird die Event Fahrt vom Server geladen
            rideViewModel.fetchEventRideDetail(eventRideId: rideId)
        }
    }
    
    // Funktion zum Übersetzen von Koordinaten in eine Adresse
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

extension EventRideDetailView {
    // Details zur Event Fahrt
    private func detailsSection(rideDetail: GetEventRideDetailDTO) -> some View {
        Section(header: Text("Fahrtdetails")) {
            Text("Event: \(rideDetail.eventName)")
            Text("Fahrer: \(rideDetail.driverName)")
            Text("Fahrzeug: \(rideDetail.vehicleDescription ?? "Keine Angabe")")
            Text("Startzeit: \(DateTimeFormatter.formatDate(rideDetail.starts)) um \(DateTimeFormatter.formatTime(rideDetail.starts))")
            Text("Freie Plätze: \(rideDetail.emptySeats)")
        }
    }
    
    // Angaben zum Ort
    private func placeSection(rideDetail: GetEventRideDetailDTO) -> some View {
        Section(header: Text("Startort")) {
            Button(action: {
                UIPasteboard.general.string = address // Text in die Zwischenablage kopieren
            }) {
                HStack{
                    Text("\(address)")
                    .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Image(systemName: "doc.on.doc").foregroundColor(.blue)
                }
                
            }.buttonStyle(PlainButtonStyle())
        }
        .onAppear {
            // Sobald diese Section geladen wird, wird die Adresse aktualisiert
            updateAddress(for: CLLocationCoordinate2D(latitude: Double(rideDetail.latitude), longitude: Double(rideDetail.longitude)))
        }
    }
    
    // Angaben zu Mitfahrern
    private func participationsSection(rideDetail: GetEventRideDetailDTO) -> some View {
        Section(header: Text("Mitfahrer")) {
            if rideDetail.riders.isEmpty {
                Text("Keine Mitfahrer")
            } else {
                ForEach(rideDetail.riders, id: \.id) { rider in
                    Text(rider.username)
                }
            }
        }
    }
    
}
