import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class Attendance: Model, @unchecked Sendable {
    public static let schema = "attendances"
    
    public final class IDValue: Fields, Hashable, @unchecked Sendable {
        @Parent(key: "meeting_id")
        public var meeting: Meeting
        
        @Field(key: "user_id")
        public var userId: UUID // TODO: userId: UUID durch user: User austauschen
        
        public init() {}
        
        public convenience init(meeting: Meeting, userId: UUID) throws {
            try self.init(meetingId: meeting.requireID(), userId: userId)
        }

        public init(meetingId: Meeting.IDValue, userId: UUID) {
            self.$meeting.id = meetingId
            self.userId = userId
        }

        public static func == (lhs: IDValue, rhs: IDValue) -> Bool {
            lhs.$meeting.id == rhs.$meeting.id && lhs.userId == rhs.userId
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.$meeting.id)
            hasher.combine(self.userId)
        }
        
    }
    
    @CompositeID()
    public var id: IDValue?

    @Field(key: "name")
    public var name: String

    @Field(key: "status")
    public var status: AttendanceStatus

    public init() { }
    
    public init(id: IDValue, name: String, status: AttendanceStatus) {
        self.id = id
        self.name = name
        self.status = status
    }
}

public enum AttendanceStatus: String, Codable, @unchecked Sendable {
    case present
    case absent
    case accepted
}
