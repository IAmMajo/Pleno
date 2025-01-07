import Foundation

public struct GetMeetingDTO: Codable {
    public var id: UUID
    public var name: String
    public var description: String
    public var status: MeetingStatus
    public var start: Date
    public var duration: UInt16?
    public var location: GetLocationDTO?
    public var chair: GetIdentityDTO?
    public var code: String?
    public var myAttendanceStatus: AttendanceStatus?
    
    public init(id: UUID, name: String, description: String, status: MeetingStatus, start: Date, duration: UInt16? = nil, location: GetLocationDTO? = nil, chair: GetIdentityDTO? = nil, code: String? = nil, myAttendanceStatus: AttendanceStatus? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.status = status
        self.start = start
        self.duration = duration
        self.location = location
        self.chair = chair
        self.code = code
        self.myAttendanceStatus = myAttendanceStatus
    }
}

public enum MeetingStatus: String, Codable, CaseIterable {
    case scheduled
    case inSession
    case completed
}

