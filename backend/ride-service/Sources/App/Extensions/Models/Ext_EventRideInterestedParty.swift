import Models
import RideServiceDTOs

extension EventRideInterestedParty {
    
    public func patchWithDTO(dto: PatchInterestedPartyDTO) {
        if let latitude = dto.latitude {
            self.latitude = latitude
        }
        
        if let longitude = dto.longitude {
            self.longitude = longitude
        }
    }
}
