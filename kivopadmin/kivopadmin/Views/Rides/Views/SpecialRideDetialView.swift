import SwiftUI
import MapKit
import RideServiceDTOs

struct SpecialRideDetailView: View {
    // ViewModel wird als EnvironmentObject geladen
    @EnvironmentObject private var rideViewModel: RideViewModel
    
    // Id der Fahrt
    var rideId: UUID
    
    // Vorbereitungen, um Koordinaten in Adressen zu übersetzen
    private let geocoder = CLGeocoder()
    @State private var address: String = "Adresse wird geladen..."
    
    var body: some View {
        List {
            // Wird angezeigt, wenn ein Details zu einer Fahrt geladen wurden
            if let rideDetail = rideViewModel.specialRideDetail {
                
                // Details zur Fahrt
                detailsSection(rideDetail: rideDetail)

                // Hier wird die Adresse angezeigt
                placeSection(rideDetail: rideDetail)

                // Mitfahrer
                participantsSection(rideDetail: rideDetail)
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
    
    // Adresse für Koordinaten abrufen
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

extension SpecialRideDetailView{
    // Details zur Sonderfahrt
    private func detailsSection(rideDetail: GetSpecialRideDetailDTO) -> some View {
        Section(header: Text("Fahrtdetails")) {
            Text("Fahrt: \(rideDetail.name)")
            Text("Fahrer: \(rideDetail.driverName)")
            Text("Fahrzeug: \(rideDetail.vehicleDescription ?? "Keine Angabe")")
            Text("Startzeit: \(DateTimeFormatter.formatDate(rideDetail.starts)) um \(DateTimeFormatter.formatTime(rideDetail.starts))")
            Text("Endzeit: \(DateTimeFormatter.formatDate(rideDetail.ends)) um \(DateTimeFormatter.formatTime(rideDetail.ends))")
            Text("Freie Plätze: \(rideDetail.emptySeats)")
        }
    }
    
    // Angaben zum Ort
    private func placeSection(rideDetail: GetSpecialRideDetailDTO) -> some View {
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
    }
    
    // Mitfahrer
    private func participantsSection(rideDetail: GetSpecialRideDetailDTO) -> some View {
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
