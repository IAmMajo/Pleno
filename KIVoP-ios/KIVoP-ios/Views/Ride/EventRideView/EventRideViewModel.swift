import Foundation
import RideServiceDTOs

class EventRideViewModel: ObservableObject {
    var event: GetEventDTO
    
    init(event: GetEventDTO){
        self.event = event
    }
}
