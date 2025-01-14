import Models
import RideServiceDTOs

extension EventParticipant {
    
    public func patchWithDTO(dto: PatchEventParticipationDTO) {
        if let participates = dto.participates {
            self.participates = participates
        }
    }
}
