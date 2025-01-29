import SwiftUI
import MapKit

struct SpecialRideDetailView: View {
    @EnvironmentObject private var rideViewModel: RideViewModel
    var rideId: UUID
    
    private let geocoder = CLGeocoder()
    @State private var address: String = "Adresse wird geladen..."
    
    var body: some View {
        List {
            if let rideDetail = rideViewModel.specialRideDetail {
                Section(header: Text("Fahrtdetails")) {
                    Text("Fahrt: \(rideDetail.name)")
                    Text("Fahrer: \(rideDetail.driverName)")
                    Text("Fahrzeug: \(rideDetail.vehicleDescription ?? "Keine Angabe")")
                    Text("Startzeit: \(DateTimeFormatter.formatDate(rideDetail.starts)) um \(DateTimeFormatter.formatTime(rideDetail.starts))")
                    Text("Endzeit: \(DateTimeFormatter.formatDate(rideDetail.ends)) um \(DateTimeFormatter.formatTime(rideDetail.ends))")
                    Text("Freie Plätze: \(rideDetail.emptySeats)")
                }

                Section(header: Text("Startort")) {
                    Button(action: {
                        UIPasteboard.general.string = address
                    }) {
                        HStack {
                            Text("\(address)")
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            Image(systemName: "doc.on.doc").foregroundColor(.blue)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .onAppear {
                    updateAddress(for: CLLocationCoordinate2D(latitude: Double(rideDetail.startLatitude), longitude: Double(rideDetail.startLongitude)))
                }

                Section(header: Text("Mitfahrer")) {
                    if rideDetail.riders.isEmpty {
                        Text("Keine Mitfahrer")
                    } else {
                        ForEach(rideDetail.riders, id: \.id) { rider in
                            Text(rider.username)
                        }
                    }
                }
            } else {
                Text("Lade Fahrtdetails...")
                    .foregroundColor(.gray)
            }
        }
        .navigationTitle("Spezialfahrt-Details")
        .onAppear {
            rideViewModel.fetchSpecialRideDetail(specialRideId: rideId)
        }
    }
    
    // 🗺️ Adresse für Koordinaten abrufen
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
                    placemark.name,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ]
                .compactMap { $0 }
                .joined(separator: ", ")
            } else {
                address = "Keine Adresse gefunden"
            }
        }
    }
}
