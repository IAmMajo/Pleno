import SwiftUI
import RideServiceDTOs
import MapKit

struct EventRideDetailView: View {
    @EnvironmentObject private var rideViewModel: RideViewModel
    var rideId: UUID
    
    private let geocoder = CLGeocoder()
    @State private var address: String = "Adresse wird geladen..."
    
    var body: some View {
        List {
            if let rideDetail = rideViewModel.eventRideDetail {
                detailsSection(rideDetail: rideDetail)

                placeSection(rideDetail: rideDetail)

                participationsSection(rideDetail: rideDetail)
            } else {
                Text("Lade Fahrtdetails...")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Fahrt-Details")
        .onAppear {
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
    private func detailsSection(rideDetail: GetEventRideDetailDTO) -> some View {
        Section(header: Text("Fahrtdetails")) {
            Text("Event: \(rideDetail.eventName)")
            Text("Fahrer: \(rideDetail.driverName)")
            Text("Fahrzeug: \(rideDetail.vehicleDescription ?? "Keine Angabe")")
            Text("Startzeit: \(DateTimeFormatter.formatDate(rideDetail.starts)) um \(DateTimeFormatter.formatTime(rideDetail.starts))")
            Text("Freie Plätze: \(rideDetail.emptySeats)")
        }
    }
    
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
            updateAddress(for: CLLocationCoordinate2D(latitude: Double(rideDetail.latitude), longitude: Double(rideDetail.longitude)))
        }
    }
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
