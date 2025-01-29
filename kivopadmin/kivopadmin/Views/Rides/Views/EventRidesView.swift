import SwiftUI
import RideServiceDTOs

struct EventRidesView: View {
    @EnvironmentObject private var rideViewModel: RideViewModel
    @State private var searchText = "" // Suchtext für die Suche

    var filteredRides: [GetEventRideDTO] {
        rideViewModel.eventRides
            .filter { $0.starts > Date() } // Nur zukünftige Fahrten
            .filter { searchText.isEmpty || $0.eventName.localizedCaseInsensitiveContains(searchText) } // Suche
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredRides, id: \.id) { eventRide in
                    NavigationLink(destination: EventRideDetailView(rideId: eventRide.id).environmentObject(rideViewModel)) {
                        Text("\(eventRide.eventName) am \(DateTimeFormatter.formatDate(eventRide.starts))")
                    }
                }
            }
            .navigationTitle("Zukünftige Fahrten")
            //.searchable(text: $searchText, prompt: "Suche nach Eventfahrten") // Suchfeld hinzufügen
        }
    }
}
