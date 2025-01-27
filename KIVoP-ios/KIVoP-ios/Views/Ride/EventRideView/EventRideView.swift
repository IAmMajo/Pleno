import SwiftUI
import CoreLocation

// Das ist die Übersicht von einem Event, in der alle Fahrten zu einem Event angezeigt werden.
struct EventRideView: View {
    @StateObject var viewModel: EventRideViewModel
    
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
        NavigationStack{
            ZStack {
                // grauer Hintergrund
                Color.gray.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                // Inhalt
                VStack{
                    Text(viewModel.formattedDate(viewModel.event.starts))
                        .padding(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .padding(.vertical)
                    
                    List {
                        if (viewModel.eventDetails != nil){
                            Section(header: Text("Event Informationen")){
                                Text(viewModel.eventDetails?.description ?? "Keine Beschreibung zu diesem Event vorhanden.")
                            }
                            Section(header: Text("Adresse")){
                                VStack(alignment: .center){
                                    Text(viewModel.address)
                                        .foregroundColor(.blue)
                                        .onTapGesture {
                                            showMapOptions = true
                                            setKoords = CLLocationCoordinate2D(
                                                latitude: CLLocationDegrees(viewModel.eventDetails!.latitude),
                                                longitude: CLLocationDegrees(viewModel.eventDetails!.longitude)
                                            )
                                            setAddress = viewModel.address
                                        }
                                    Divider()
                                        .background(Color.gray)
                                        .padding(.bottom, 10)
                                    Text("\(viewModel.eventDetails!.latitude), \(viewModel.eventDetails!.longitude)")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .onAppear(){
                                viewModel.getAddressFromCoordinates(latitude: viewModel.eventDetails!.latitude, longitude: viewModel.eventDetails!.longitude) { address in
                                    if let address = address {
                                        viewModel.address = address
                                    }
                                }
                            }
                        }
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
                        } else {
                            Section(header: Text("Fahrten")){
                                ForEach( viewModel.eventRides, id: \.id ) { ride in
                                    NavigationLink(destination: EventRideDetailView(viewModel: EventRideDetailViewModel(eventRide: ride))) {
                                        HStack {
                                            ProfilePictureRide(name: ride.driverName, id: ride.driverID)
                                            VStack{
                                                Text(ride.driverName)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                Text(viewModel.driverAddress[ride.driverID] ?? "Lädt Adresse...")
                                                    .font(.subheadline)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            if let openRequests = ride.openRequests, openRequests > 0 {
                                                Image(systemName: "\(openRequests).circle.fill")
                                                    .aspectRatio(1, contentMode: .fit)
                                                    .foregroundStyle(.orange)
                                                    .padding(.trailing, 5)
                                            }
                                            HStack{
                                                Text("\(ride.allocatedSeats) / \(ride.emptySeats)")
                                                Image(systemName: "car.fill" )
                                            }
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
                                            Image(systemName: "square.and.arrow.up")
                                                .foregroundColor(.blue)
                                                .onTapGesture {
                                                    showMapOptions = true
                                                    setKoords = CLLocationCoordinate2D(
                                                        latitude: CLLocationDegrees(ride.latitude),
                                                        longitude: CLLocationDegrees(ride.longitude)
                                                    )
                                                    setAddress = viewModel.driverAddress[ride.driverID]
                                                }
                                        }
                                    }
                                }
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
                    Task {
                        viewModel.fetchEventDetails()
                        viewModel.fetchEventRides()
                    }
                }
                .refreshable {
                    Task {
                        viewModel.fetchEventDetails()
                        viewModel.fetchEventRides()
                    }
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
        .navigationTitle(viewModel.event.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
