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
    @State private var isEditSheetPresented = false
    
    var body: some View {
        VStack{
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
                NavigationStack{
                    if let eventDetail = eventViewModel.eventDetail {
                        List {
                            // Event Description
                            descriptionSection(eventDetail: eventDetail)

                            // Event Dates
                            dateSection(eventDetail: eventDetail)
                            
                            if address != "" {
                                // Adresse des Events
                                addressSection(eventDetail: eventDetail)
                            }
                            
                            // Participants
                            participantsSection(eventDetail: eventDetail)

                            // Users Without Feedback
                            userWithoutFeedbackSection(eventDetail: eventDetail)

                            // Ride Information
                            rideSection(eventDetail: eventDetail)

                        }
                        .navigationTitle(eventDetail.name)
                        .onAppear {
                            updateAddress(for: CLLocationCoordinate2D(latitude: Double(eventDetail.latitude), longitude: Double(eventDetail.longitude)))
                        }
                        .refreshable{
                            eventViewModel.fetchEventDetail(eventId: eventId)
                        }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    isEditSheetPresented = true
                                }) {
                                    Text("Bearbeiten")
                                    //Label("Bearbeiten", systemImage: "pencil")
                                }
                            }
                        }
                        .sheet(isPresented: $isEditSheetPresented) {
                            EditEventView(eventDetail: eventDetail, eventId: eventId)
                        }
                    }

                }
            }
        }
        .onAppear {
            eventViewModel.fetchEventDetail(eventId: eventId)
            eventViewModel.fetchEventRides(eventId: eventId)
        }
        



    }
    
    // Koordinaten zu Adresse übersetzen
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

extension EventDetailView {
    private func descriptionSection(eventDetail: GetEventDetailDTO) -> some View {
        Section(header: Text("Beschreibung")) {
            if let description = eventDetail.description {
                Text(description)
            } else {
                Text("Keine Beschreibung verfügbar")
                    .italic()
                    .foregroundColor(.gray)
            }
        }
        
    }
    
    private func dateSection(eventDetail: GetEventDetailDTO) -> some View {
        Section(header: Text("Datum und Zeit")) {
            HStack {
                Text("Start:")
                Spacer()
                Text("Am \(DateTimeFormatter.formatDate(eventDetail.starts)) um \(DateTimeFormatter.formatTime(eventDetail.starts))")
            }
            HStack {
                Text("Ende:")
                Spacer()
                Text("Am \(DateTimeFormatter.formatDate(eventDetail.ends)) um \(DateTimeFormatter.formatTime(eventDetail.ends))")
            }
        }
    }
    
    private func addressSection(eventDetail: GetEventDetailDTO) -> some View  {
        Section(header: Text("Adresse")) {
            Button(action: {
                UIPasteboard.general.string = address // Text in die Zwischenablage kopieren
            }) {
                HStack{
                    Text(address)
                    .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Image(systemName: "doc.on.doc").foregroundColor(.blue)
                }
                
            }.buttonStyle(PlainButtonStyle())

        }
        .onAppear {
            updateAddress(for: CLLocationCoordinate2D(
                latitude: Double(eventDetail.latitude),
                longitude: Double(eventDetail.longitude)
            ))
        }
    }
    
    private func participantsSection(eventDetail: GetEventDetailDTO) -> some View {
        Section(header: Text("Teilnehmer")) {
            if eventDetail.participations.isEmpty {
                Text("Keine Teilnehmer")
                    .italic()
            } else {
                ForEach(eventDetail.participations, id: \.id) { participant in
                    Text("\(participant.name)")
                }
            }
        }
    }
    
    private func userWithoutFeedbackSection(eventDetail: GetEventDetailDTO) -> some View {
        Section(header: Text("Teilnehmer ohne Feedback")) {
            if eventDetail.userWithoutFeedback.isEmpty {
                Text("Keine Teilnehmer ohne Feedback")
                    .italic()
            } else {
                ForEach(Array(eventDetail.userWithoutFeedback.enumerated()), id: \.offset) { index, user in
                    Text("\(user.name)")
                }
            }
        }
    }
    private func rideSection(eventDetail: GetEventDetailDTO) -> some View {
        Group {
            Section(header: Text("Fahrt-Informationen")) {
                Text("Interessiert an Mitfahrgelegenheiten: \(eventDetail.countRideInterested)")
                Text("Freie Plätze: \(eventDetail.countEmptySeats)")
            }

            if !eventViewModel.eventRides.isEmpty {
                Section(header: Text("Eventfahrten")) {
                    ForEach(eventViewModel.eventRides, id: \.id) { ride in
                        NavigationLink(destination: EventRideDetailView(rideId: ride.id)) {
                            Text("Fahrer: \(ride.driverName)")
                        }
                    }
                }
            }
        }
    }

}

