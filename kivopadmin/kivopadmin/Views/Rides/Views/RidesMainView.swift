import SwiftUI
import RideServiceDTOs

struct RidesMainView: View {
    @StateObject private var rideViewModel = RideViewModel()
    @State private var selectedRideType: RideType = .eventRides

    enum RideType: String, CaseIterable {
        case eventRides = "Eventfahrten"
        case specialRides = "Sonderfahrten"
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Fahrttyp auswählen", selection: $selectedRideType) {
                    ForEach(RideType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Dynamische Anzeige der jeweiligen View
                if selectedRideType == .eventRides {
                    EventRidesView().environmentObject(rideViewModel)
                } else {
                    SpecialRidesView().environmentObject(rideViewModel)
                }
                
                // Hier könntest du später eine Liste der ausgewählten Fahrten anzeigen
            }
            .navigationTitle("Fahrgemeinschaften")
        }
        .onAppear {
            rideViewModel.fetchEventRides()
            rideViewModel.fetchSpecialRides()
        }
    }
}
