import SwiftUI

struct RideDetailView: View {
    @StateObject var viewModel: RideDetailViewModel
    
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
                    
                    List{
                        Text("Zielort - als Bild")
                        Text("Adresse")
                        Text("Geokoordinaten")
                        Section(header: Text("Beschreibung Auto")){
                            if let vehicleDescription = viewModel.rideDetail.vehicleDescription {
                                Text(vehicleDescription)
                            } else {
                                Text("Keine Fahrzeugbeschreibung vorhanden.")
                            }
                        }
                        Section(header: Text("Fahrer")){
                            Text(viewModel.rideDetail.driverName)
                        }
                        Section(header: Text("Mitfahrer")){
                            if viewModel.rideDetail.riders.isEmpty {
                                Text("Keine Mitfahrer")
                            } else {
                                ForEach(viewModel.rideDetail.riders, id: \.id) { rider in
                                    HStack {
                                        Text(rider.name)
                                        Spacer()
                                        Image(systemName:
                                                rider.status ? "checkmark.circle" : "questionmark.circle"
                                        )
                                        .foregroundColor(
                                            rider.status ? .blue : .orange
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    RideDecision(viewModel: viewModel)
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
        .navigationTitle(viewModel.ride.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
