import Foundation
import RideServiceDTOs

class EventRideViewModel: ObservableObject {
    var ride: GetSpecialRideDTO
    
    init(ride: GetSpecialRideDTO){
        self.ride = ride
    }
}
