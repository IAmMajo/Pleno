import SwiftUI
import RideServiceDTOs

struct MyRidesList: View {
    var rides: [Any]
    @ObservedObject var viewModel: RideViewModel
    
    var body: some View {
        ForEach(rides.indices, id: \.self) { index in
            if let ride = rides[index] as? GetSpecialRideDTO {
                rideRow(for: ride)
            } else if let eventRide = rides[index] as? GetEventRideDTO {
                eventRideRow(for: eventRide)
            }
        }
    }
    
    @ViewBuilder
    private func rideRow(for ride: GetSpecialRideDTO) -> some View {
        NavigationLink(destination: RideDetailView(viewModel: RideDetailViewModel(ride: ride), rideViewModel: viewModel)) {
            HStack {
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
                HStack {
                    Text("\(ride.allocatedSeats) / \(ride.emptySeats)")
                    Image(systemName: "car.fill")
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
    
    @ViewBuilder
    private func eventRideRow(for eventRide: GetEventRideDTO) -> some View {
        NavigationLink(destination: EventRideDetailView(viewModel: EventRideDetailViewModel(eventRide: eventRide))) {
            HStack {
                VStack(alignment: .leading) {
                    HStack{
                        Image(systemName: "star")
                            .padding(.trailing, -5)
                        Text("\(eventRide.eventName)")
                            .font(.headline)
                    }
                    Text(DateTimeFormatter.formatDate(eventRide.starts))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Spacer()
                if let openRequests = eventRide.openRequests, openRequests > 0 {
                    Image(systemName: "\(openRequests).circle.fill")
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundStyle(.orange)
                        .padding(.trailing, 5)
                }
                HStack{
                    Text("\(eventRide.allocatedSeats) / \(eventRide.emptySeats)")
                    Image(systemName: "car.fill" )
                }
                .foregroundColor(
                    {
                        switch eventRide.myState {
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
