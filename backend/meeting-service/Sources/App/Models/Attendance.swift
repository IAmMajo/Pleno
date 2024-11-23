import Models
import MeetingServiceDTOs

extension Attendance {
    public func toGetAttendanceDTO() throws -> GetAttendanceDTO {
        try .init(meetingId: self.requireID().meeting.requireID(), identity: self.requireID().identity.toGetIdentityDTO(), status: self.status.convert())
    }
}
