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
