import SwiftUI
import RideServiceDTOs

struct RideList: View {
    var rides: [GetSpecialRideDTO]
    
    var body: some View {
        ForEach(rides, id: \.id) { ride in
            NavigationLink(destination: RideDetailView(viewModel: RideDetailViewModel(ride: ride))) {
                HStack{
                    VStack(alignment: .leading) {
                        Text(ride.name)
                            .font(.headline)
                        Text(DateTimeFormatter.formatDate(ride.starts))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    HStack{
                        Text("\(ride.allocatedSeats) / \(ride.emptySeats)")
                        Image(systemName: "car.fill" )
                    }
                    .foregroundColor(
                        ride.isSelfDriver ? .blue : .gray
                    )
                    .font(.system(size: 15))
                }
            }
        }
    }
}
