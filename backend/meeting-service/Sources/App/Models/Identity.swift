import Models
import MeetingServiceDTOs

extension Identity {
    public func toGetIdentityDTO() throws -> GetIdentityDTO {
        .init(id: try self.requireID(), name: self.name)
    }
}
