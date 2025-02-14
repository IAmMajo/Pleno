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
import CoreLocation

// Das ist die Übersicht von einem Event, in der alle Fahrten zu einem Event angezeigt werden.
struct EventRideView: View {
    @StateObject var viewModel: EventRideViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            // Den gesamten Hintergrund grau hinterlegen (Damit alles so aussieht als wäre es eine Liste)
            ZStack {
                (colorScheme == .dark ? Color.black : Color.gray.opacity(0.1))
                            .edgesIgnoringSafeArea(.all)
                // Inhalt
                VStack{
                    // Datum vom Event
                    Text(viewModel.rideManager.formattedDate(viewModel.event.starts))
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .padding(.vertical)
                    
                    List {
                        // Event Informationen
                        if (viewModel.eventDetails != nil){
                            Section(header: Text("Event Informationen")){
                                Text(viewModel.eventDetails?.description ?? "Keine Beschreibung zu diesem Event vorhanden.")
                            }
                            // Adresse vom Ziel zum Event
                            Section(header: Text("Adresse")){
                                VStack(alignment: .center){
                                    Text(viewModel.address)
                                        .foregroundColor(.blue)
                                        // Dialog um die Adresse zu kopieren oder zu öffnen
                                        .onTapGesture {
                                            viewModel.showMapOptions = true
                                            viewModel.setKoords = CLLocationCoordinate2D(
                                                latitude: CLLocationDegrees(viewModel.eventDetails!.latitude),
                                                longitude: CLLocationDegrees(viewModel.eventDetails!.longitude)
                                            )
                                            viewModel.setAddress = viewModel.address
                                        }
                                    Divider()
                                        .background(Color.gray)
                                        .padding(.bottom, 10)
                                    // Koordinaten
                                    Text("\(viewModel.eventDetails!.latitude), \(viewModel.eventDetails!.longitude)")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            // Adresse wird ermittelt
                            .onAppear(){
                                viewModel.rideManager.getAddressFromCoordinates(latitude: viewModel.eventDetails!.latitude, longitude: viewModel.eventDetails!.longitude) { address in
                                    if let address = address {
                                        viewModel.address = address
                                    }
                                }
                            }
                        }
                        // Wenn der Nutzer dem Event noch nicht zugesagt hat, kann er auch nicht an einer Fahrgemeinschaft teilnehmen
                        if (viewModel.event.myState != .present){
                            Text("Du hast dem ausgewählten Event nicht zugesagt, und kannst daher keiner Fahrgemeinschaft beitreten.")
                                .padding(.horizontal)
                            Button(action: {
                                viewModel.participateEvent()
                            }){
                                Text("Jetzt zusagen!")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .buttonStyle(PlainButtonStyle())
                        // Wenn der Nutzer nicht Fahrer bei dem Event ist, oder seinen Abholort noch nicht festgelegt hat, muss er das erst tun bevor er die Fahrten sehen kann
                        } else if viewModel.interestedEvent == nil && !viewModel.eventRides.contains(where: { $0.myState == .driver }) {
                            Text("Bevor du einer Eventfahrt beitreten kannst, musst du deinen Standort festlegen. Dieser kann später noch über das Symbol oben rechts geändert werden.")
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button(action: {
                                viewModel.showLocationRequest = true
                            }){
                                Text("Jetzt Abholort angeben.")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            // Fahrten die keine freien Plätze haben werden nicht angezeigt
                            if !(viewModel.eventRides.filter { $0.emptySeats - $0.allocatedSeats > 0 }).isEmpty {
                                Section(header: Text("Fahrten")){
                                    ForEach( viewModel.eventRides.filter { $0.emptySeats - $0.allocatedSeats > 0 }, id: \.id ) { ride in
                                        NavigationLink(destination: EventRideDetailView(viewModel: EventRideDetailViewModel(eventRide: ride))) {
                                            HStack {
                                                // Profilbild des Fahrers
                                                ProfilePictureRide(name: ride.driverName, id: ride.driverID)
                                                VStack{
                                                    // Name des Fahrers
                                                    Text(ride.driverName)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                    // Adresse des Fahrers
                                                    Text(viewModel.driverAddress[ride.driverID] ?? "Lädt Adresse...")
                                                        .font(.subheadline)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .foregroundColor(.gray)
                                                }
                                                Spacer()
                                                // Offene Requests zu einer Fahrt (falls vorhanden)
                                                if let openRequests = ride.openRequests, openRequests > 0 {
                                                    Image(systemName: "\(openRequests).circle.fill")
                                                        .aspectRatio(1, contentMode: .fit)
                                                        .foregroundStyle(.orange)
                                                        .padding(.trailing, 5)
                                                }
                                                // belegte/freie Plätze
                                                HStack{
                                                    Text("\(ride.allocatedSeats) / \(ride.emptySeats)")
                                                    Image(systemName: "car.fill" )
                                                }
                                                // Status des Nutzers bei der Eventfahrt
                                                .foregroundColor(
                                                    {
                                                        switch ride.myState {
                                                        case .driver:
                                                            return Color.blue
                                                        case .nothing:
                                                            return Color.gray
                                                        case .requested:
                                                            return Color.orange
                                                        case .accepted:
                                                            return Color.green
                                                        }
                                                    }()
                                                )
                                                .font(.system(size: 15))
                                                // Dialog um Standort des Fahrers zu öffen/kopieren
                                                Image(systemName: "square.and.arrow.up")
                                                    .foregroundColor(.blue)
                                                    .onTapGesture {
                                                        viewModel.showMapOptions = true
                                                        viewModel.setKoords = CLLocationCoordinate2D(
                                                            latitude: CLLocationDegrees(ride.latitude),
                                                            longitude: CLLocationDegrees(ride.longitude)
                                                        )
                                                        viewModel.setAddress = viewModel.driverAddress[ride.driverID]
                                                    }
                                            }
                                        }
                                    }
                                }
                            } else {
                                Text("Es wurden noch keine Fahrgemeinschaften zu diesem Event angelegt.")
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
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
        }
        // Dialog für den Standort
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
        // sheet für die Zwischenablage (Nur der Text für die Adresse)
        .sheet(isPresented: $viewModel.shareLocation) {
            ShareSheet(activityItems: [viewModel.formattedShareText()])
               .presentationDetents([.medium, .large])
               .presentationDragIndicator(.hidden)
        }
        .navigationTitle(viewModel.event.name)
        .navigationBarTitleDisplayMode(.inline)
        // Abholort für das Event bearbeiten
        .toolbar {
            if !viewModel.eventRides.contains(where: { $0.myState == .driver }) {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.blue)
                        // Wenn der Nutzer vorher noch keinen Standort festgelegt hatte, setzt er hier seinen Abholort initial
                        .onTapGesture {
                            if viewModel.interestedEvent != nil {
                                viewModel.editInterestEvent = true
                            }
                            viewModel.showLocationRequest = true
                        }
                }
            }
        }
        // .sheet() für die Location Request (Wenn ich dem Event Zusage muss ich meine Location setzen)
        .sheet(isPresented: $viewModel.showLocationRequest, onDismiss: {
            viewModel.fetchParticipation()
            viewModel.editInterestEvent = false
        }) {
            EventRideLocationRequestView(viewModel: viewModel)
        }
    }
}
