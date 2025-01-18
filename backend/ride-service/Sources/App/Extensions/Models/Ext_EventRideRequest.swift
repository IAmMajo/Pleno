import Models
import RideServiceDTOs

extension EventRideRequest {
    
    public func patchWithDTO(dto: PatchEventRideRequestDTO) {
        self.accepted = dto.accepted
    }
}
