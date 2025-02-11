import SwiftUI
import RideServiceDTOs

struct EventList: View {
    var events: [EventWithAggregatedData]
    @ObservedObject var viewModel: RideViewModel
    
    // Diese Komponente zeigt eine Liste von Events im Reiter "Events" an
    // Hierbei werden aggregatedEvents verwendet, da hierbei die kummulierten Statistiken zu Eventfahrten drin stehen
    var body: some View {
        ForEach(events, id: \.event.id) { aggregatedEvent in
            NavigationLink(destination: EventRideView(viewModel: EventRideViewModel(event: aggregatedEvent.event))) {
                HStack {
                    VStack(alignment: .leading) {
                        // Name
                        // Das Event selber ist aggregatedEvent.event
                        Text(aggregatedEvent.event.name)
                            .font(.headline)
                        // Datum
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
                    
                    // Zeigt die aggregierte Anzahl der belegten und freien Sitze an
                    HStack {
                        Text("\(aggregatedEvent.allAllocatedSeats) / \(aggregatedEvent.allEmptySeats)")
                        Image(systemName: "car.fill")
                    }
                    // Farbgebung basierend auf dem Status des Nutzers
                    // Es wird der höchste Status angezeigt
                    // driver > accepted > requested
                    .foregroundColor(
                        {
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
