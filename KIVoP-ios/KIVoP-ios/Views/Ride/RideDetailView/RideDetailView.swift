import SwiftUI

struct RideDetailView: View {
    @StateObject var viewModel: RideDetailViewModel
    @ObservedObject var rideViewModel: RideViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // grauer Hintergrund
                Color.gray.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                // Inhalt
                VStack {
                    Text(viewModel.formattedDate(viewModel.rideDetail.starts))
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .padding(.vertical)
                    
                    // Wenn man Fahrer ist nie anzeigen
                    if !viewModel.rideDetail.isSelfDriver && viewModel.rider?.accepted == false {
                        Text("Du hast bereits angefragt mitgenommen zu werden.")
                            .font(.headline)
                            .frame(maxWidth: 250, alignment: .center)
                    }
                    
                    List{
                        
                        Section(header: Text("Fahrtbeschreibung")){
                            Text(viewModel.rideDetail.description ?? "Keine Beschreibung vorhanden")
                        }
                        
                        Section(header: Text("Ort")){
                            Text("Zielort - als Bild")
                            Text("Adresse")
                            Text("Geokoordinaten")
                        }

                        Section(header: Text("Beschreibung Auto")){
                            if let vehicleDescription = viewModel.rideDetail.vehicleDescription {
                                Text(vehicleDescription)
                            } else {
                                Text("Keine Fahrzeugbeschreibung vorhanden.")
                            }
                        }
                        Section(header: Text("Fahrer")){
                            HStack{
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 40, height: 40)
                                VStack{
                                    Text(viewModel.rideDetail.driverName)
                                    Text("Adresse")
                                        .font(.subheadline)
                                }
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.blue)
                                    .onTapGesture {
                                        print("Standort kopiert!")
                                    }
                            }
                        }
                        
                        Section(header: Text("Mitfahrer (\(viewModel.acceptedRiders.count)/\(viewModel.rideDetail.emptySeats))")){
                            if viewModel.acceptedRiders.isEmpty {
                                Text("Keine Mitfahrer")
                            } else {
                                // Mitgenommen
                                ForEach(viewModel.acceptedRiders, id: \.id) { rider in
                                    HStack {
                                        VStack{
                                            Text(rider.username)
                                            Text("Adresse")
                                                .font(.subheadline)
                                        }
                                        Spacer()
                                        if viewModel.rideDetail.isSelfDriver {
                                            Image(systemName: "square.and.arrow.up")
                                                .foregroundColor(.blue)
                                                .onTapGesture {
                                                    print("Standort kopiert!")
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
                                                            viewModel.fetchRideDetails()
                                                        },
                                                        secondaryButton: .cancel()
                                                    )
                                                }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if viewModel.requestedRiders.isEmpty {
                        // Nichts wird angezeigt wenn es keine Requests gibt
                        } else {
                            // Anfragen
                            Section(header: Text("Anfragen zum Mitnehmen (\(viewModel.requestedRiders.count))")){
                                ForEach(viewModel.requestedRiders, id: \.id) { rider in
                                    HStack {
                                        VStack{
                                            Text(rider.username)
                                            Text("Adresse")
                                                .font(.subheadline)
                                        }
                                        Spacer()
                                        if viewModel.rideDetail.isSelfDriver {
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
                                                            viewModel.fetchRideDetails()
                                                        },
                                                        secondaryButton: .cancel()
                                                    )
                                                }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    RideDecision(viewModel: viewModel, rideViewModel: rideViewModel)
                }
            }
            .overlay {
                if viewModel.isLoading {
                  ProgressView("Lädt...")
               }
            }
            .onAppear {
               Task {
                   viewModel.fetchRideDetails()
               }
            }
            .refreshable {
                Task {
                    viewModel.fetchRideDetails()
                }
            }
        }
        .navigationTitle(viewModel.rideDetail.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            if viewModel.rideDetail.isSelfDriver {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: EditSpecialRideView(viewModel: EditRideViewModel(ride: viewModel.rideDetail, selectedOption: viewModel.selectedOption))) {
                        Text("Bearbeiten")
                            .font(.body)
                    }
                }
            }
        }
        // .sheet() für die Location Request
        .sheet(isPresented: $viewModel.showLocationRequest) {
            LocationRequestView(viewModel: viewModel)
        }
    }
}
