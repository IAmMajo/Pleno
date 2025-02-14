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

// Diese Komponente zeigt eine Liste von Fahrten im Reiter "Meine Fahrten" an
struct MyRidesList: View {
    var rides: [Any]
    @ObservedObject var viewModel: RideViewModel
    
    var body: some View {
        // Durchläuft die Liste der Fahrten und entscheidet anhand des Typs, welche Detailansicht geöffnet wird
        ForEach(rides.indices, id: \.self) { index in
            if let ride = rides[index] as? GetSpecialRideDTO {
                rideRow(for: ride) {
                    RideDetailView(viewModel: RideDetailViewModel(ride: ride), rideViewModel: viewModel)
                }
            } else if let eventRide = rides[index] as? GetEventRideDTO {
                rideRow(for: eventRide) {
                    EventRideDetailView(viewModel: EventRideDetailViewModel(eventRide: eventRide))
                }
            }
        }
    }
    
    // Funktion zur Darstellung einer Fahrt in der Liste
    @ViewBuilder
    private func rideRow<T>(for ride: T, destination: @escaping () -> some View) -> some View {
        NavigationLink(destination: destination()) {
            HStack {
                VStack(alignment: .leading) {
                    if let eventRide = ride as? GetEventRideDTO {
                        // Falls es sich um eine Event-Fahrt handelt, wird zusätzlich ein Stern-Icon angezeigt
                        HStack {
                            Image(systemName: "star")
                                .padding(.trailing, -5)
                            // Name für EventRide
                            Text(eventRide.eventName)
                                .font(.headline)
                        }
                    } else if let specialRide = ride as? GetSpecialRideDTO {
                        // Name für SpecialRide
                        Text(specialRide.name)
                            .font(.headline)
                    }
                    // Datum
                    if let date = (ride as? GetSpecialRideDTO)?.starts ?? (ride as? GetEventRideDTO)?.starts {
                        Text(DateTimeFormatter.formatDate(date))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                // Falls es offene Anfragen gibt, wird dies durch ein Icon dargestellt
                // Nur wenn man selbst der Fahrer ist, werden vom Server offene Requests zurückgegeben
                if let openRequests = (ride as? GetSpecialRideDTO)?.openRequests ?? (ride as? GetEventRideDTO)?.openRequests,
                   openRequests > 0 {
                    Image(systemName: "\(openRequests).circle.fill")
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundStyle(.orange)
                        .padding(.trailing, 5)
                }
                // Zeigt die Anzahl der belegten und freien Sitze an
                HStack {
                    if let allocatedSeats = (ride as? GetSpecialRideDTO)?.allocatedSeats ?? (ride as? GetEventRideDTO)?.allocatedSeats,
                       let emptySeats = (ride as? GetSpecialRideDTO)?.emptySeats ?? (ride as? GetEventRideDTO)?.emptySeats {
                        Text("\(allocatedSeats) / \(emptySeats)")
                    }
                    Image(systemName: "car.fill")
                }
                // Farbgebung basierend auf dem Status des Nutzers in der Fahrt
                .foregroundColor(
                    {
                        if let myState = (ride as? GetSpecialRideDTO)?.myState ?? (ride as? GetEventRideDTO)?.myState {
                            switch myState {
                            case .driver:
                                return Color.blue
                            case .nothing:
                                return Color.gray
                            case .requested:
                                return Color.orange
                            case .accepted:
                                return Color.green
                            }
                        }
                        return Color.gray
                    }()
                )
                .font(.system(size: 15))
            }
        }
    }
}
