import Models
import RideServiceDTOs

extension EventParticipant {
    
    public func patchWithDTO(dto: PatchEventParticipationDTO) {
        self.participates = dto.participates
    }
}
