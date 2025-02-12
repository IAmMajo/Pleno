// This file is licensed under the MIT-0 License.
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
