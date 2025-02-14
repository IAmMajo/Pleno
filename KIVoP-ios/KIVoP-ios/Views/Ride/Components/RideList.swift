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

struct RideList: View {
    var rides: [GetSpecialRideDTO]
    @ObservedObject var viewModel: RideViewModel
    
    // Diese Komponente zeigt eine Liste von Fahrten im Reiter "Sonstige Fahrten" an
    var body: some View {
        ForEach(rides, id: \.id) { ride in
            NavigationLink(destination: RideDetailView(viewModel: RideDetailViewModel(ride: ride), rideViewModel: viewModel)) {
                HStack{
                    VStack(alignment: .leading) {
                        // Name
                        Text(ride.name)
                            .font(.headline)
                        // Datum
                        Text(DateTimeFormatter.formatDate(ride.starts))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    // Falls es offene Anfragen gibt, wird dies durch ein Icon dargestellt
                    // Nur wenn man selbst der Fahrer ist, werden vom Server offene Requests zurückgegeben
                    if let openRequests = ride.openRequests, openRequests > 0 {
                        Image(systemName: "\(openRequests).circle.fill")
                            .aspectRatio(1, contentMode: .fit)
                            .foregroundStyle(.orange)
                            .padding(.trailing, 5)
                    }
                    // Zeigt die Anzahl der belegten und freien Sitze an
                    HStack{
                        Text("\(ride.allocatedSeats) / \(ride.emptySeats)")
                        Image(systemName: "car.fill" )
                    }
                    // Farbgebung basierend auf dem Status des Nutzers in der Fahrt
                    .foregroundColor(
                        {
                            switch ride.myState {
                            case .driver:
                                return Color.blue
                            case .nothing:
                                return Color.gray
                            case .requested:
                                return Color.orange
                            case .accepted:
                                return Color.green
                            }
                        }()
                    )
                    .font(.system(size: 15))
                }
            }
        }
    }
}
