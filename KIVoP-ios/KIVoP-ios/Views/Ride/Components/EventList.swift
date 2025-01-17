import SwiftUI
import RideServiceDTOs

struct EventList: View {
    var rides: [GetSpecialRideDTO]
    
    var body: some View {
        ForEach(rides, id: \.id) { ride in
            NavigationLink(destination: EventRideView(viewModel: EventRideViewModel(ride: ride))) {
                HStack{
                    VStack(alignment: .leading) {
                        Text(ride.name)
                            .font(.headline)
                        Text(DateTimeFormatter.formatDate(ride.starts))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}
