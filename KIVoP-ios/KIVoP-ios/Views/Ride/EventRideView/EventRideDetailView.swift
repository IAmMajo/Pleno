// This file is licensed under the MIT-0 License.
import SwiftUI
import Foundation
import MapKit

struct EventRideDetailView: View {
    @StateObject var viewModel: EventRideDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var shouldShowDriversProfilePicture = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            // Den gesamten Hintergrund grau hinterlegen (Damit alles so aussieht als wäre es eine Liste)
            ZStack {
                (colorScheme == .dark ? Color.black : Color.gray.opacity(0.1))
                            .edgesIgnoringSafeArea(.all)
                // Inhalt
                VStack {
                    // Datum + Uhrzeit
                    Text(viewModel.rideManager.formattedDate(viewModel.eventRideDetail.starts))
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color(UIColor.label), lineWidth: 1)
                        )
                        .padding(.vertical)
                    
                    // Wenn man requested hat wird das angezeigt
                    if !viewModel.eventRideDetail.isSelfDriver && viewModel.rider?.accepted == false {
                        Text("Du hast bereits angefragt mitgenommen zu werden.")
                            .font(.headline)
                            .frame(maxWidth: 250, alignment: .center)
                    }
                
                    Section(header: Text("Event Beschreibung").font(.headline)){
                        Text(viewModel.eventDetails.description ?? "Keine Beschreibung zum Event vorhanden")
                            .multilineTextAlignment(.center)
                    }
                    
                    Section(header: Text("Informationen zur Fahrt").font(.headline)){
                        Text(viewModel.eventRideDetail.description ?? "Keine Beschreibung zur Fahrt vorhanden")
                            .multilineTextAlignment(.center)
                    }

                    // Karte mit Eventort
                    RideLocationView(selectedLocation: $viewModel.eventLocation)
                        .cornerRadius(10)
                        .frame(width: 350, height: 150)
                    Text(viewModel.eventAddress)
                        .foregroundColor(.blue)
                        // Event Adresse onAppear berechnen
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                viewModel.rideManager.getAddressFromCoordinates(latitude: viewModel.eventDetails.latitude, longitude: viewModel.eventDetails.longitude) { address in
                                    if let address = address {
                                        viewModel.eventAddress = address
                                    }
                                }
                            }
                        }
                        // Adresse vom Event anzeigen lassen
                        .onTapGesture {
                            viewModel.showMapOptions = true
                            viewModel.setKoords = CLLocationCoordinate2D(
                                latitude: CLLocationDegrees(viewModel.eventDetails.latitude),
                                longitude: CLLocationDegrees(viewModel.eventDetails.longitude)
                            )
                            viewModel.setAddress = viewModel.eventAddress
                        }
                    // Eventkoordinaten
                    Text("\(viewModel.eventDetails.latitude), \(viewModel.eventDetails.longitude)")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    List{
                        // Anzeigen des Fahrers
                        Section(header: Text("Fahrer")){
                            HStack{
                                // Leichte Verzögerung damit Daten geladen sind
                                if shouldShowDriversProfilePicture {
                                    ProfilePictureRide(name: viewModel.eventRideDetail.driverName, id: viewModel.eventRideDetail.driverID)
                                }
                                VStack{
                                    // Name des Fahrers
                                    Text(viewModel.eventRideDetail.driverName)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    // Adresse des Fahrers
                                    Text(viewModel.driverAddress)
                                        .font(.subheadline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.gray)
                                        // Profilbild mit leichter Verzögerung laden, da die benötigten Daten leicht verzögert gesetzt werden
                                        // Adresse aus den Koordinaten berechnen
                                        .onAppear {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                shouldShowDriversProfilePicture = true
                                                viewModel.rideManager.getAddressFromCoordinates(latitude: viewModel.eventRideDetail.latitude, longitude: viewModel.eventRideDetail.longitude) { address in
                                                    if let address = address {
                                                        viewModel.driverAddress = address
                                                    }
                                                }
                                            }
                                        }
                                }
                                Spacer()
                                // Standort vom Fahrer anzeigen lassen
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.blue)
                                    .onTapGesture {
                                        viewModel.showMapOptions = true
                                        viewModel.setKoords = CLLocationCoordinate2D(
                                            latitude: CLLocationDegrees(viewModel.eventRideDetail.latitude),
                                            longitude: CLLocationDegrees(viewModel.eventRideDetail.longitude)
                                        )
                                        viewModel.setAddress = viewModel.driverAddress
                                    }
                            }
                        }

                        // Alle Akzeptierten Mitfahrer werden angezeigt
                        Section(header: Text("Mitfahrer (\(viewModel.acceptedRiders.count)/\(viewModel.eventRideDetail.emptySeats))")){
                            if viewModel.acceptedRiders.isEmpty {
                                Text("Keine Mitfahrer")
                            } else {
                                // Mitgenommene Mitfahrer
                                ForEach(viewModel.acceptedRiders, id: \.id) { rider in
                                    HStack {
                                        // Profilbild
                                        ProfilePictureRide(name: rider.username, id: rider.userID)
                                        VStack{
                                            // Name
                                            Text(rider.username)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            // Adresse ist nur für den Fahrer sichtbar
                                            if viewModel.eventRideDetail.isSelfDriver {
                                                Text(viewModel.riderAddresses[rider.id] ?? "Lädt Adresse...")
                                                    .font(.subheadline)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        Spacer()
                                        // Optionen für Standort kopieren und Mitfahrer löschen nur für den Fahrer
                                        if viewModel.eventRideDetail.isSelfDriver {
                                            Image(systemName: "square.and.arrow.up")
                                                .foregroundColor(.blue)
                                                .onTapGesture {
                                                    viewModel.showMapOptions = true
                                                    viewModel.setKoords = CLLocationCoordinate2D(
                                                        latitude: CLLocationDegrees(rider.latitude),
                                                        longitude: CLLocationDegrees(rider.longitude)
                                                    )
                                                    viewModel.setAddress = viewModel.riderAddresses[rider.id]
                                                }
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                                .onTapGesture {
                                                    // Mitfahrer löschen für den Fahrer
                                                    viewModel.showPassengerDeleteRequest = true
                                                }
                                                // Fahrer entfernt einen angenommenen Mitfahrer
                                                .alert(isPresented: $viewModel.showPassengerDeleteRequest) {
                                                    Alert(
                                                        title: Text("Bestätigung"),
                                                        message: Text("Möchten Sie die Person wirklich aus der Fahrgemeinschaft entfernen?"),
                                                        primaryButton: .destructive(Text("Entfernen")) {
                                                            // Aktion zum Löschen für den Fahrer
                                                            viewModel.removeFromPassengers(rider: rider)
                                                        },
                                                        secondaryButton: .cancel()
                                                    )
                                                }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if viewModel.requestedRiders.isEmpty || !viewModel.eventRideDetail.isSelfDriver {
                        // Nichts wird angezeigt wenn es keine offenen Requests gibt oder man nicht Fahrer ist
                        } else {
                            // Alle Anfragen zu einer Eventfahrt
                            Section(header: Text("Anfragen zum Mitnehmen (\(viewModel.requestedRiders.count))")){
                                ForEach(viewModel.requestedRiders, id: \.id) { rider in
                                    HStack {
                                        // Profilbild
                                        ProfilePictureRide(name: rider.username, id: rider.userID)
                                        VStack{
                                            // Name des Mitfahrers
                                            Text(rider.username)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            // Adresse des Mitfahrers
                                            Text(viewModel.riderAddresses[rider.id] ?? "Lädt Adresse...")
                                                .font(.subheadline)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.green)
                                            .onTapGesture {
                                                // Akzeptieren für den Fahrer
                                                viewModel.showPassengerAddRequest = true
                                            }
                                            // Fahrer akzeptiert Request
                                            .alert(isPresented: $viewModel.showPassengerAddRequest) {
                                                Alert(
                                                    title: Text("Bestätigung"),
                                                    message: Text("Möchten Sie die Person wirklich zu der Fahrgemeinschaft hinzufügen?"),
                                                    primaryButton: .default(Text("Hinzufügen")) {
                                                        // Aktion zum hinzufügen für den Fahrer
                                                        viewModel.acceptRequestedRider(rider: rider)
                                                    },
                                                    secondaryButton: .cancel()
                                                )
                                            }
                                    }
                                }
                            }
                        }
                        // Beschreibung zum Auto
                        Section(header: Text("Beschreibung Auto")){
                            if let vehicleDescription = viewModel.eventRideDetail.vehicleDescription {
                                Text(vehicleDescription)
                            } else {
                                Text("Keine Fahrzeugbeschreibung vorhanden.")
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    // Button für Aktionen zu der EventFahrt
                    // Je nach Status des Nutzers wird eine andere Aktion angezeigt/ausgeführt
                    EventRideDecision(viewModel: viewModel )
                }
            }
            .overlay {
                if viewModel.isLoading {
                  ProgressView("Lädt...")
               }
            }
            .onAppear {
               viewModel.fetchAllUpdates()
            }
            .refreshable {
                viewModel.fetchAllUpdates()
            }
        }
        // Dialog wenn der Nutzer den Standort kopieren möchte
        .confirmationDialog("Standort außerhalb der Anwendung öffnen?", isPresented: $viewModel.showMapOptions) {
           Button("Öffnen mit Apple Maps") {
              NavigationAppHelper.shared.openInAppleMaps(
                name: viewModel.setAddress,
                coordinate: viewModel.setKoords!
              )
           }
            if viewModel.isGoogleMapsInstalled {
              Button("Öffnen mit Google Maps") {
                  NavigationAppHelper.shared.openInGoogleMaps(name: viewModel.setAddress, coordinate: viewModel.setKoords!)
              }
           }
            if viewModel.isWazeInstalled {
              Button("Öffnen mit Waze") {
                  NavigationAppHelper.shared.openInWaze(coordinate: viewModel.setKoords!)
              }
           }
           Button("Teilen...") {
               viewModel.shareLocation = true
           }
           Button("Abbrechen", role: .cancel) {}
        }
        // Für die Zwischenablage
        .sheet(isPresented: $viewModel.shareLocation) {
            ShareSheet(activityItems: [viewModel.formattedShareText()])
               .presentationDetents([.medium, .large])
               .presentationDragIndicator(.hidden)
        }
        .navigationTitle(viewModel.eventRide.eventName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            if viewModel.eventRideDetail.isSelfDriver {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: EditEventRideView(viewModel: EditRideViewModel(eventRideDetail: viewModel.eventRideDetail))) {
                        Text("Bearbeiten")
                            .font(.body)
                    }
                }
            }
        }
    }
}
