import SwiftUI
import MapKit

struct RideDetailView: View {
    @StateObject var viewModel: RideDetailViewModel
    @ObservedObject var rideViewModel: RideViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // grauer Hintergrund um die View an den Prototypen anzupassen
                Color.gray.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                // Inhalt
                VStack {
                    // Datum
                    Text(viewModel.rideManager.formattedDate(viewModel.rideDetail.starts))
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .padding(.vertical)
                    
                    // Wenn ein Nutzer eine Anffrage gestellt hat wird dieser Text angezeigt
                    if !viewModel.rideDetail.isSelfDriver && viewModel.rider?.accepted == false {
                        Text("Du hast bereits angefragt mitgenommen zu werden.")
                            .font(.headline)
                            .frame(maxWidth: 250, alignment: .center)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Fahrtbeschreibung
                    Text("Beschreibung zur Fahrt: ")
                        .font(.headline)
                    Text(viewModel.rideDetail.description ?? "Keine Beschreibung zur Fahrt vorhanden")
                        .multilineTextAlignment(.center)

                    // Zielort
                    // Karte zur Ansicht mit Adresse
                    RideLocationView(selectedLocation: $viewModel.location)
                        .cornerRadius(10)
                        .frame(width: 350, height: 150)
                    Text(viewModel.destinationAddress)
                        .foregroundColor(.blue)
                        // Um die Adresse mit einer Funktion zu berechnen wird onAppear verwendet
                        // asyncAfter, damit der Standort vorhanden ist, bevor die Funktion aufgerufen wird
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                viewModel.getAddressFromCoordinates(latitude: viewModel.rideDetail.destinationLatitude, longitude: viewModel.rideDetail.destinationLongitude) { address in
                                    if let address = address {
                                        viewModel.destinationAddress = address
                                    }
                                }
                            }
                        }
                        // Beim Klick auf die Adresse wird ein Dialog geöffnet
                        // Hier kann gewählt werden womit die Koordinaten geöffnet werden sollen (Maps etc.)
                        .onTapGesture {
                            viewModel.showMapOptions = true
                            viewModel.setKoords = CLLocationCoordinate2D(
                                latitude: CLLocationDegrees(viewModel.rideDetail.destinationLatitude),
                                longitude: CLLocationDegrees(viewModel.rideDetail.destinationLongitude)
                            )
                            viewModel.setAddress = viewModel.destinationAddress
                        }
                    // Koordinaten des Zielortes
                    Text("\(viewModel.rideDetail.destinationLatitude), \(viewModel.rideDetail.destinationLongitude)")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    List{
                        // Der Fahrer wird abgebildet
                        Section(header: Text("Fahrer")){
                            HStack{
                                // Profilbild des Fahrers wird etwas später geladen, da es sonst nicht lädt
                                if viewModel.shouldShowDriversProfilePicture {
                                    ProfilePictureRide(name: viewModel.rideDetail.driverName, id: viewModel.rideDetail.driverID)
                                }
                                VStack{
                                    // Name
                                    Text(viewModel.rideDetail.driverName)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    // Adresse
                                    Text(viewModel.driverAddress)
                                        .font(.subheadline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.gray)
                                        // Um die Adresse mit einer Funktion zu berechnen wird onAppear verwendet
                                        // asyncAfter, damit der Standort vorhanden ist, bevor die Funktion aufgerufen wird
                                        // Außerdem wird das Profilbild etwas später erst geladen
                                        .onAppear {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                viewModel.shouldShowDriversProfilePicture = true
                                                viewModel.getAddressFromCoordinates(latitude: viewModel.rideDetail.startLatitude, longitude: viewModel.rideDetail.startLongitude) { address in
                                                    if let address = address {
                                                        viewModel.driverAddress = address
                                                    }
                                                }
                                            }
                                        }
                                }
                                Spacer()
                                // Aufrufen des Standorts mit einem Dialog
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.blue)
                                    .onTapGesture {
                                        viewModel.showMapOptions = true
                                        viewModel.setKoords = CLLocationCoordinate2D(
                                            latitude: CLLocationDegrees(viewModel.rideDetail.startLatitude),
                                            longitude: CLLocationDegrees(viewModel.rideDetail.startLongitude)
                                        )
                                        viewModel.setAddress = viewModel.driverAddress
                                    }
                            }
                        }
                        
                        // Alle akzeptierten Mitfahrer werden hier angezeigt
                        // Außerdem wie viele Leute bereits akzeptiert sind, und wie viele Plätze es gibt
                        Section(header: Text("Mitfahrer (\(viewModel.acceptedRiders.count)/\(viewModel.rideDetail.emptySeats))")){
                            if viewModel.acceptedRiders.isEmpty {
                                Text("Keine Mitfahrer")
                            } else {
                                // Mitgenommen Fahrer
                                ForEach(viewModel.acceptedRiders, id: \.id) { rider in
                                    HStack {
                                        // Profilbild
                                        ProfilePictureRide(name: rider.username, id: rider.userID)
                                        VStack{
                                            // Name
                                            Text(rider.username)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            // Wenn man Fahrer ist, wird die Adresse der Person angezeigt
                                            // Wenn man kein Fahrer ist, hat man keinen Zugriff auf die Adresse der anderen Mitfahrer
                                            if viewModel.rideDetail.isSelfDriver {
                                                Text(viewModel.riderAddresses[rider.id] ?? "Lädt Adresse...")
                                                    .font(.subheadline)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        Spacer()
                                        // Aufrufen des Standorts mit einem Dialog (nur als Fahrer sichtbar)
                                        if viewModel.rideDetail.isSelfDriver {
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
                                            // Mitfahrer entfernen
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                                .onTapGesture {
                                                    // Dialog wird angezeigt, ob der Mitfahrer entfernt werden soll
                                                    viewModel.showPassengerDeleteRequest = true
                                                }
                                                // Fahrer entfernt einen angenommenen Mitfahrer
                                                .alert(isPresented: $viewModel.showPassengerDeleteRequest) {
                                                    Alert(
                                                        title: Text("Bestätigung"),
                                                        message: Text("Möchten Sie die Person wirklich aus der Fahrgemeinschaft entfernen?"),
                                                        primaryButton: .destructive(Text("Entfernen")) {
                                                            // Mitfahrer wird entfernt und steht wieder als requestedRider
                                                            // Der Rider wird an die remove Funktion übertragen
                                                            viewModel.removeFromPassengers(rider: rider)
                                                        },
                                                        // Mitfahrer wird nicht entfernt
                                                        secondaryButton: .cancel()
                                                    )
                                                }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Wenn man der Fahrer ist, werden RequestedRiders angezeigt
                        if viewModel.requestedRiders.isEmpty || !viewModel.rideDetail.isSelfDriver {
                        // Wenn es keine requestedRiders gibt, wird die Section nicht angezeigt.
                        } else {
                            // Anfragen
                            Section(header: Text("Anfragen zum Mitnehmen (\(viewModel.requestedRiders.count))")){
                                ForEach(viewModel.requestedRiders, id: \.id) { rider in
                                    HStack {
                                        // Profilbild
                                        ProfilePictureRide(name: rider.username, id: rider.userID)
                                        VStack{
                                            // Name
                                            Text(rider.username)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            // Adresse
                                            Text(viewModel.riderAddresses[rider.id] ?? "Lädt Adresse...")
                                                .font(.subheadline)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        // Option einen Mitfahrer hinzuzufügen
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
                            if let vehicleDescription = viewModel.rideDetail.vehicleDescription {
                                Text(vehicleDescription)
                            } else {
                                Text("Keine Fahrzeugbeschreibung vorhanden.")
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    // Der Button, der verschiedene Funktionen erfüllen kann, je nachdem welchen Status man bei der Fahrt hat
                    SpecialRideDecision(viewModel: viewModel, rideViewModel: rideViewModel)
                }
            }
            .overlay {
                if viewModel.isLoading {
                  ProgressView("Lädt...")
               }
            }
            .onAppear {
               viewModel.fetchRideDetails()
            }
            .refreshable {
                viewModel.fetchRideDetails()
            }
        }
        // Dialog zur Auswahl der Option für die Adresse
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
        // Wenn im confirmationDialog die Adresse geteilt werden soll (Teilt den Namen der Adresse)
        .sheet(isPresented: $viewModel.shareLocation) {
            ShareSheet(activityItems: [viewModel.formattedShareText()])
               .presentationDetents([.medium, .large])
               .presentationDragIndicator(.hidden)
        }
        .navigationTitle(viewModel.rideDetail.name)
        .navigationBarTitleDisplayMode(.inline)
        // Dem Fahrer wird die Option angezeigt die Fahrt zu bearbeiten
        .toolbar{
            if viewModel.rideDetail.isSelfDriver {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: EditSpecialRideView(viewModel: EditRideViewModel(rideDetail: viewModel.rideDetail))) {
                        Text("Bearbeiten")
                            .font(.body)
                    }
                }
            }
        }
        // .sheet() für den Location Request
        .sheet(isPresented: $viewModel.showLocationRequest) {
            SpecialRideLocationRequestView(viewModel: viewModel)
        }
    }
}
