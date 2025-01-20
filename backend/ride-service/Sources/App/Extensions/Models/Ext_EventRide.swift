import Models
import RideServiceDTOs

extension EventRide {
    
    public func patchWithDTO(dto: PatchEventRideDTO) {
        
        if let description = dto.description {
            self.description = description
        }
        
        if let vehicleDescription = dto.vehicleDescription {
            self.vehicleDescription = vehicleDescription
        }
        
        if let starts = dto.starts {
            self.starts = starts
        }
        
        if let latitude = dto.latitude {
            self.latitude = latitude
        }
        
        if let longitude = dto.longitude {
            self.longitude = longitude
        }
        
        if let emptySeats = dto.emptySeats {
            self.emptySeats = emptySeats
        }
    }
}
