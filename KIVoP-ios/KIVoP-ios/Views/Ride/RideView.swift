import SwiftUI

struct RideView: View {
    @StateObject private var viewModel = RideViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingNewRideAlert = false
    @State private var navigateToNewRide = false
    
    var body: some View {
        NavigationStack {
            // Inhalt
            VStack {
                // Fahrgemeinschaften
                List {
                    // TabView Event Fahrten, Sonstige, meine Fahrten
                    Picker("", selection: $viewModel.selectedTab) {
                        Text("Events").tag(0)
                        Text("Sonderfahrten").tag(1)
                        Text("Meine Fahrten").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    
                    ForEach(viewModel.groupedRides, id: \.key) { group in
                        Section(header: Text(group.key)
                            .padding(.leading, -5)
                        ) {
                            if viewModel.selectedTab == 0 {
                                //EventList(events: group.value)
                            } else if viewModel.selectedTab == 1 {
                                RideList(rides: group.value, viewModel: viewModel)
                            } else {
                                MyRidesList(rides: group.value, viewModel: viewModel)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .overlay {
                    if viewModel.isLoading {
                      ProgressView("Lädt...")
                   }
                }
                .onAppear {
                   Task {
                       viewModel.fetchSpecialRides()
                   }
                }
                .refreshable {
                    Task {
                        viewModel.fetchSpecialRides()
                    }
                }
            }
            .navigationTitle("Fahrgemeinschaften")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                // Neue Fahrt anbieten
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: NewRideView(viewModel: EditRideViewModel(), rideViewModel: viewModel)) {
                        Text("Neue Fahrt anbieten")
                            .font(.body)
                    }
                }
                // Zurück Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Zurück")
                                .font(.body)
                        }
                    }
                }
            }
        }
    }
}
