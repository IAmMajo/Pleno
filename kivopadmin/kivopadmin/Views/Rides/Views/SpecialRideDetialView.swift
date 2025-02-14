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
