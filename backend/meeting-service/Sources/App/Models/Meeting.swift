import Models
import MeetingServiceDTOs

extension Meeting {
    public func toGetMeetingDTO() throws -> GetMeetingDTO {
        try .init(id: self.requireID(),
              name: self.name,
              description: self.description,
              status: self.status.convert(),
              start: self.start, duration: self.duration,
              location: self.location?.toGetLocationDTO(),
              chair: self.chair?.toGetIdentityDTO(),
              code: self.code)
    }
}
