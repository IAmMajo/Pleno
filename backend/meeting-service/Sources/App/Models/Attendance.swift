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
        
        @Field(key: "identity_id")
        public var identityId: UUID // TODO: identityId: UUID durch identity: Identity austauschen
        
        public init() {}
        
        public convenience init(meeting: Meeting, identityId: UUID) throws {
            try self.init(meetingId: meeting.requireID(), identityId: identityId)
        }

        public init(meetingId: Meeting.IDValue, identityId: UUID) {
            self.$meeting.id = meetingId
            self.identityId = identityId
        }

        public static func == (lhs: IDValue, rhs: IDValue) -> Bool {
            lhs.$meeting.id == rhs.$meeting.id && lhs.identityId == rhs.identityId
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.$meeting.id)
            hasher.combine(self.identityId)
        }
        
    }
    
    @CompositeID()
    public var id: IDValue?

    @Field(key: "status")
    public var status: AttendanceStatus

    public init() { }
    
    public init(id: IDValue, status: AttendanceStatus) {
        self.id = id
        self.status = status
    }
}

public enum AttendanceStatus: String, Codable, @unchecked Sendable {
    case present
    case absent
    case accepted
}
