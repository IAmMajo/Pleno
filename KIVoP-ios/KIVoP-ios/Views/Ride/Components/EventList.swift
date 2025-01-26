import SwiftUI
import RideServiceDTOs

struct EventList: View {
    var events: [GetEventDTO]
    
    var body: some View {
        ForEach(events, id: \.id) { event in
            NavigationLink(destination: EventRideView(viewModel: EventRideViewModel(event: event))) {
                HStack{
                    VStack(alignment: .leading) {
                        Text(event.name)
                            .font(.headline)
                        Text(DateTimeFormatter.formatDate(event.starts))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}
