import SwiftUI
import RideServiceDTOs

struct EventList: View {
    var events: [EventWithAggregatedData]
    @ObservedObject var viewModel: RideViewModel
    
    var body: some View {
        ForEach(events, id: \.event.id) { aggregatedEvent in
            NavigationLink(destination: EventRideView(viewModel: EventRideViewModel(event: aggregatedEvent.event))) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(aggregatedEvent.event.name)
                            .font(.headline)
                        Text(DateTimeFormatter.formatDate(aggregatedEvent.event.starts))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                    // Anzeige der offenen Anfragen, wenn vorhanden
                    if let openRequests = aggregatedEvent.allOpenRequests, openRequests > 0 {
                        Image(systemName: "\(openRequests).circle.fill")
                            .aspectRatio(1, contentMode: .fit)
                            .foregroundStyle(.orange)
                            .padding(.trailing, 5)
                    }
                    
                    HStack {
                        // Zeige die aggregierten Werte für zugewiesene und leere Plätze
                        Text("\(aggregatedEvent.allAllocatedSeats) / \(aggregatedEvent.allEmptySeats)")
                        Image(systemName: "car.fill")
                    }
                    .foregroundColor(
                        {
                            // Bestimme die Farbe basierend auf dem `myState`
                            switch aggregatedEvent.myState {
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
