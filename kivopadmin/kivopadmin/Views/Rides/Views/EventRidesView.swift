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
                // Unterscheidung, ob Fahrten vorhanden sind
                if filteredRides.isEmpty {
                    Section {
                        Text("Keine Fahrten vorhanden.")
                            .foregroundColor(.gray)
                    }
                } else {
                    ForEach(filteredRides, id: \.id) { eventRide in
                        NavigationLink(destination: EventRideDetailView(rideId: eventRide.id).environmentObject(rideViewModel)) {
                            Text("\(eventRide.eventName) am \(DateTimeFormatter.formatDate(eventRide.starts))")
                        }
                    }
                }
            }
            .navigationTitle("Zukünftige Fahrten")
            //.searchable(text: $searchText, prompt: "Suche nach Eventfahrten") // Suchfeld hinzufügen
        }
    }
}
