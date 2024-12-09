import Foundation

public struct GetAttendanceDTO: Codable {
    public var meetingId: UUID
    public var identity: GetIdentityDTO
    public var status: AttendanceStatus?
    public var itsame: Bool // it's-a me
    
    public init(meetingId: UUID, identity: GetIdentityDTO, status: AttendanceStatus? = nil, itsame: Bool = false) {
        self.meetingId = meetingId
        self.identity = identity
        self.status = status
        self.itsame = itsame
    }
}

public enum AttendanceStatus: String, Codable {
    case present
    case absent
    case accepted
}

