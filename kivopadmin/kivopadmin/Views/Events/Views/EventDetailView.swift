import SwiftUI
import PosterServiceDTOs
import PhotosUI
import MapKit
import RideServiceDTOs
import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject private var eventViewModel: EventViewModel
    private let geocoder = CLGeocoder()
    @State private var address: String = "Adresse wird geladen..."
    var eventId: UUID
    
    var body: some View {
        ScrollView {
            if eventViewModel.isLoading {
                ProgressView("Lade Event...") // Ladeanzeige
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let errorMessage = eventViewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else if eventViewModel.eventDetail == nil {
                Text("Das Event konnte nicht geladen werden.")
                    .foregroundColor(.secondary)
            } else {
                if let eventDetail = eventViewModel.eventDetail {
                    VStack(alignment: .leading, spacing: 16) {
                        // Event Name
                        Text(eventDetail.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 8)
                        
                        // Description
                        if let description = eventDetail.description {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Keine Beschreibung verfügbar")
                                .italic()
                                .foregroundColor(.gray)
                        }
                        
                        // Dates
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Start:")
                                    .fontWeight(.semibold)
                                Text(eventDetail.starts, style: .date)
                            }
                            HStack {
                                Text("Ende:")
                                    .fontWeight(.semibold)
                                Text(eventDetail.ends, style: .date)
                            }
                        }
                        
                        // Location (Latitude and Longitude)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Location:")
                                .fontWeight(.semibold)
                            Text("Latitude: \(eventDetail.latitude)")
                            Text("Longitude: \(eventDetail.longitude)")
                        }
                        
                        // Participations
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Teilnehmer:")
                                .fontWeight(.semibold)
                            if eventDetail.participations.isEmpty {
                                Text("Keine Teilnehmer")
                                    .italic()
                            } else {
                                ForEach(eventDetail.participations, id: \.id) { participation in
                                    Text("- \(participation.name)")
                                }
                            }
                        }
                        
                        // Users without Feedback
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text("Teilnehmer ohne Feedback:")
//                                .fontWeight(.semibold)
//                            if eventDetail.userWithoutFeedback.isEmpty {
//                                Text("Keine Teilnehmer ohne Feedback")
//                                    .italic()
//                            } else {
//                                ForEach(eventDetail.userWithoutFeedback, id: \.id) { user in
//                                    Text("- \(user.name)")
//                                }
//                            }
//                        }
                        
                        // Ride Information
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Fahrt-Informationen:")
                                .fontWeight(.semibold)
                            Text("Interessiert an Mitfahrgelegenheiten: \(eventDetail.countRideInterested)")
                            Text("Freie Plätze: \(eventDetail.countEmptySeats)")
                        }
                    }
                    .padding()
                }
            }
        }
        .refreshable{
            eventViewModel.fetchEventDetail(eventId: eventId)
        }
        .onAppear {
            eventViewModel.fetchEventDetail(eventId: eventId)
        }
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


