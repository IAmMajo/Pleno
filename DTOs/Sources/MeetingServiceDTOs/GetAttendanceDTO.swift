import Foundation

public struct GetAttendanceDTO: Codable {
    public var meetingId: UUID
    public var identity: GetIdentityDTO
    public var status: AttendanceStatus
}

public enum AttendanceStatus: String, Codable {
    case present
    case absent
    case accepted
}

