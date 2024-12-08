import Foundation

public struct GetAttendanceDTO: Codable {
    public var meetingId: UUID
    public var identity: GetIdentityDTO
    public var status: AttendanceStatus?
    
    public init(meetingId: UUID, identity: GetIdentityDTO, status: AttendanceStatus? = nil) {
        self.meetingId = meetingId
        self.identity = identity
        self.status = status
    }
}

public enum AttendanceStatus: String, Codable {
    case present
    case absent
    case accepted
}

