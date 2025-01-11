import Models
import RideServiceDTOs

extension SpecialRideRequest {
    
    public func patchWithDTO(dto: PatchSpecialRideRequestDTO, isDriver: Bool) {
        if isDriver {
            if let accepted = dto.accepted {
                self.accepted = accepted
            }
        } else {
            if let latitude = dto.latitude {
                self.latitude = latitude
            }
            
            if let longitude = dto.longitude {
                self.longitude = longitude
            }
        }
    }
}
