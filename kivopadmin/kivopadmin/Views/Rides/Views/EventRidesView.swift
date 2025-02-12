import SwiftUI
import RideServiceDTOs

struct EventRidesView: View {
    // ViewModel wird als EnvironmentObject übergeben
    @EnvironmentObject private var rideViewModel: RideViewModel
    
    // Suchtext
    @State private var searchText = ""

    var filteredRides: [GetEventRideDTO] {
        rideViewModel.eventRides
            .filter { $0.starts > Date() } // Nur zukünftige Fahrten
            .filter { searchText.isEmpty || $0.eventName.localizedCaseInsensitiveContains(searchText) } // Suche
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredRides, id: \.id) { eventRide in
                    // Link zur Detailansicht; Das ViewModel wird als EnvironmentObject mitgegeben
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
