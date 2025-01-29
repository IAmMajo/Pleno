import SwiftUI
import Foundation
import MapKit

struct EventRideDetailView: View {
    @StateObject var viewModel: EventRideDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var shouldShowDriversProfilePicture = false
    
    // Vars um Standort zu kopieren
    @State private var shareLocation = false
    @State private var isGoogleMapsInstalled = false
    @State private var isWazeInstalled = false
    @State private var showMapOptions: Bool = false
    @State private var setKoords: CLLocationCoordinate2D?
    @State private var setAddress: String?
    private func formattedShareText() -> String {
       """
       \(setAddress ?? "")
       """
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // grauer Hintergrund
                Color.gray.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                // Inhalt
                VStack {
                    Text(viewModel.formattedDate(viewModel.eventRideDetail.starts))
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .padding(.vertical)
                    
                    // Wenn man Fahrer ist nie anzeigen
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

                    // Eventort
                    RideLocationView(selectedLocation: $viewModel.eventLocation)
                        .cornerRadius(10)
                        .frame(width: 350, height: 150)
                    Text(viewModel.eventAddress)
                        .foregroundColor(.blue)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                viewModel.getAddressFromCoordinates(latitude: viewModel.eventDetails.latitude, longitude: viewModel.eventDetails.longitude) { address in
                                    if let address = address {
                                        viewModel.eventAddress = address
                                    }
                                }
                            }
                        }
                        .onTapGesture {
                            showMapOptions = true
                            setKoords = CLLocationCoordinate2D(
                                latitude: CLLocationDegrees(viewModel.eventDetails.latitude),
                                longitude: CLLocationDegrees(viewModel.eventDetails.longitude)
                            )
                            setAddress = viewModel.eventAddress
                        }
                    Text("\(viewModel.eventDetails.latitude), \(viewModel.eventDetails.longitude)")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    List{
                        Section(header: Text("Fahrer")){
                            HStack{
                                // Leichte Verzögerung damit Daten geladen sind
                                if shouldShowDriversProfilePicture {
                                    ProfilePictureRide(name: viewModel.eventRideDetail.driverName, id: viewModel.eventRideDetail.driverID)
                                }
                                VStack{
                                    Text(viewModel.eventRideDetail.driverName)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(viewModel.driverAddress)
                                        .font(.subheadline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.gray)
                                        .onAppear {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                shouldShowDriversProfilePicture = true
                                                viewModel.getAddressFromCoordinates(latitude: viewModel.eventRideDetail.latitude, longitude: viewModel.eventRideDetail.longitude) { address in
                                                    if let address = address {
                                                        viewModel.driverAddress = address
                                                    }
                                                }
                                            }
                                        }
                                }
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.blue)
                                    .onTapGesture {
                                        showMapOptions = true
                                        setKoords = CLLocationCoordinate2D(
                                            latitude: CLLocationDegrees(viewModel.eventRideDetail.latitude),
                                            longitude: CLLocationDegrees(viewModel.eventRideDetail.longitude)
                                        )
                                        setAddress = viewModel.driverAddress
                                    }
                            }
                        }

                        Section(header: Text("Mitfahrer (\(viewModel.acceptedRiders.count)/\(viewModel.eventRideDetail.emptySeats))")){
                            if viewModel.acceptedRiders.isEmpty {
                                Text("Keine Mitfahrer")
                            } else {
                                // Mitgenommen
                                ForEach(viewModel.acceptedRiders, id: \.id) { rider in
                                    HStack {
                                        // Profilbild
                                        ProfilePictureRide(name: rider.username, id: rider.userID)
                                        VStack{
                                            Text(rider.username)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            if viewModel.eventRideDetail.isSelfDriver {
                                                Text(viewModel.riderAddresses[rider.id] ?? "Lädt Adresse...")
                                                    .font(.subheadline)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        Spacer()
                                        if viewModel.eventRideDetail.isSelfDriver {
                                            Image(systemName: "square.and.arrow.up")
                                                .foregroundColor(.blue)
                                                .onTapGesture {
                                                    showMapOptions = true
                                                    setKoords = CLLocationCoordinate2D(
                                                        latitude: CLLocationDegrees(rider.latitude),
                                                        longitude: CLLocationDegrees(rider.longitude)
                                                    )
                                                    setAddress = viewModel.riderAddresses[rider.id]
                                                }
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                                .onTapGesture {
                                                    // Mitfahrer löschen für den Fahrer
                                                    viewModel.rider = rider
                                                    viewModel.showPassengerDeleteRequest = true
                                                }
                                                // Fahrer entfernt einen angenommenen Mitfahrer
                                                .alert(isPresented: $viewModel.showPassengerDeleteRequest) {
                                                    Alert(
                                                        title: Text("Bestätigung"),
                                                        message: Text("Möchten Sie die Person wirklich aus der Fahrgemeinschaft entfernen?"),
                                                        primaryButton: .destructive(Text("Entfernen")) {
                                                            // Aktion zum Löschen für den Fahrer
                                                            viewModel.removeFromPassengers(rider: viewModel.rider!)
                                                            viewModel.showPassengerDeleteRequest = false
                                                            viewModel.fetchEventRideDetails()
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
                        // Nichts wird angezeigt wenn es keine Requests gibt oder man nicht Fahrer ist
                        } else {
                            // Anfragen
                            Section(header: Text("Anfragen zum Mitnehmen (\(viewModel.requestedRiders.count))")){
                                ForEach(viewModel.requestedRiders, id: \.id) { rider in
                                    HStack {
                                        // Profilbild
                                        ProfilePictureRide(name: rider.username, id: rider.userID)
                                        VStack{
                                            Text(rider.username)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            if viewModel.eventRideDetail.isSelfDriver {
                                                Text(viewModel.riderAddresses[rider.id] ?? "Lädt Adresse...")
                                                    .font(.subheadline)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        Spacer()
                                        if viewModel.eventRideDetail.isSelfDriver {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.green)
                                                .onTapGesture {
                                                    // Akzeptieren für den Fahrer
                                                    viewModel.rider = rider
                                                    viewModel.showPassengerAddRequest = true
                                                }
                                                // Fahrer akzeptiert Request
                                                .alert(isPresented: $viewModel.showPassengerAddRequest) {
                                                    Alert(
                                                        title: Text("Bestätigung"),
                                                        message: Text("Möchten Sie die Person wirklich zu der Fahrgemeinschaft hinzufügen?"),
                                                        primaryButton: .default(Text("Hinzufügen")) {
                                                            // Aktion zum hinzufügen für den Fahrer
                                                            viewModel.acceptRequestedRider(rider: viewModel.rider!)
                                                            viewModel.showPassengerAddRequest = false
                                                            viewModel.fetchEventRideDetails()
                                                        },
                                                        secondaryButton: .cancel()
                                                    )
                                                }
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
                    EventRideDecision(viewModel: viewModel )
                }
            }
            .overlay {
                if viewModel.isLoading {
                  ProgressView("Lädt...")
               }
            }
            .onAppear {
               Task {
                   viewModel.fetchEventRideDetails()
                   viewModel.fetchEventDetails()
                   viewModel.fetchEventRides()
               }
            }
            .refreshable {
                Task {
                    viewModel.fetchEventRideDetails()
                    viewModel.fetchEventDetails()
                    viewModel.fetchEventRides()
                }
            }
        }
        .sheet(isPresented: $shareLocation) {
            ShareSheet(activityItems: [formattedShareText()])
               .presentationDetents([.medium, .large])
               .presentationDragIndicator(.hidden)
        }
        .confirmationDialog("Standort außerhalb der Anwendung öffnen?", isPresented: $showMapOptions) {
           Button("Öffnen mit Apple Maps") {
              NavigationAppHelper.shared.openInAppleMaps(
                name: setAddress,
                coordinate: setKoords!
              )
           }
           if isGoogleMapsInstalled {
              Button("Öffnen mit Google Maps") {
                 NavigationAppHelper.shared.openInGoogleMaps(name: setAddress, coordinate: setKoords!)
              }
           }
           if isWazeInstalled {
              Button("Öffnen mit Waze") {
                 NavigationAppHelper.shared.openInWaze(coordinate: setKoords!)
              }
           }
           Button("Teilen...") {
              shareLocation = true
           }
           Button("Abbrechen", role: .cancel) {}
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
