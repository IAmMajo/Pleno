import Models
import MeetingServiceDTOs

extension Record {
    public func toGetRecordDTO() throws -> GetRecordDTO {
        try .init(meetingId: self.requireID().meeting.requireID(),
                  lang: self.requireID().lang,
                  identity: self.identity.toGetIdentityDTO(),
                  status: self.status.convert(),
                  content: self.content)
    }
}
