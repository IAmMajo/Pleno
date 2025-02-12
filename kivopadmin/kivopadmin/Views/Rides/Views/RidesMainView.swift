import SwiftUI
import RideServiceDTOs

struct RidesMainView: View {
    
    // ViewModel wird einmalig initialisiert und zu jeder "Unterview" mitgegeben
    @StateObject private var rideViewModel = RideViewModel()
    
    // Status für den Picker
    @State private var selectedRideType: RideType = .eventRides

    // Variablen für den Picker
    enum RideType: String, CaseIterable {
        case eventRides = "Eventfahrten"
        case specialRides = "Sonderfahrten"
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Picker um Fahrttyp zu wählen
                Picker("Fahrttyp auswählen", selection: $selectedRideType) {
                    ForEach(RideType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Dynamische Anzeige der jeweiligen View
                // Link zu den Unteransichten; ViewModel wird als EnvironmentObject mitgegeben
                if selectedRideType == .eventRides {
                    EventRidesView().environmentObject(rideViewModel)
                } else {
                    SpecialRidesView().environmentObject(rideViewModel)
                }
            }
            .navigationTitle("Fahrgemeinschaften")
        }
        .onAppear {
            // Beim Aufruf der View werden die Sonderfahrten und Eventfahrten vom Server geholt
            rideViewModel.fetchEventRides()
            rideViewModel.fetchSpecialRides()
        }
    }
}
