import Foundation
import CoreLocation
import MapKit
import RideServiceDTOs

@MainActor
class EventRideDetailViewModel: ObservableObject {
    @Published var eventRide: GetEventRideDTO
    
    init(eventRide: GetEventRideDTO) {
        self.eventRide = eventRide
    }
}
