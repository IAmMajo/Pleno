import SwiftUI
import RideServiceDTOs

struct RideView: View {
    @StateObject private var viewModel = RideViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingNewRideAlert = false
    @State private var navigateToNewRide = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Liste für gruppierte Daten
                List {
                    // Picker für die Tabs (Events, Sonderfahrten, Meine Fahrten)
                    Picker("", selection: $viewModel.selectedTab) {
                        Text("Events").tag(0)
                        Text("Sonderfahrten").tag(1)
                        Text("Meine Fahrten").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    // Alle Daten werden gruppiert
                    // Je nach Gruppe wird eine andere View geladen um die Daten anzuzeigen
                    ForEach(viewModel.groupedData, id: \.key) { group in
                        Section(header: Text(group.key)
                            .padding(.leading, -5)
                        ) {
                            // Überprüfe, welche Liste angezeigt wird, basierend auf dem ausgewählten Tab
                            if viewModel.selectedTab == 0 { // Events
                                EventList(events: group.value as! [EventWithAggregatedData], viewModel: viewModel)
                            } else if viewModel.selectedTab == 1 { // Sonderfahrten
                                RideList(rides: group.value as! [GetSpecialRideDTO], viewModel: viewModel)
                            } else { // Meine Fahrten
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
                   viewModel.fetchRides()
                }
                .refreshable {
                    viewModel.fetchRides()
                }
            }
            .navigationTitle("Fahrgemeinschaften")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                // Neue Fahrt anbieten
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: {
                        let editRideViewModel = EditRideViewModel()
                        // Extrahiere nur die GetEventDTO-Objekte aus EventWithAggregatedData
                        editRideViewModel.events = viewModel.events.map { $0.event }
                        return NewRideView(viewModel: editRideViewModel, rideViewModel: viewModel)
                    }()) {
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
