import SwiftUI
import RideServiceDTOs

struct MyRidesList: View {
    var rides: [GetSpecialRideDTO]
    @ObservedObject var viewModel: RideViewModel
    
    var body: some View {
        ForEach(rides, id: \.id) { ride in
            NavigationLink(destination: RideDetailView(viewModel: RideDetailViewModel(ride: ride), rideViewModel: viewModel)) {
                HStack{
                    VStack(alignment: .leading) {
                        Text(ride.name)
                            .font(.headline)
                        Text(DateTimeFormatter.formatDate(ride.starts))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if let openRequests = ride.openRequests, openRequests > 0 {
                        Image(systemName: "\(openRequests).circle.fill")
                            .aspectRatio(1, contentMode: .fit)
                            .foregroundStyle(.orange)
                            .padding(.trailing, 5)
                    }
                    HStack{
                        Text("\(ride.allocatedSeats) / \(ride.emptySeats)")
                        Image(systemName: "car.fill" )
                    }
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
