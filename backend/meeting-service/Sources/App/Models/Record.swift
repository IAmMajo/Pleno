import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class Record: Model, @unchecked Sendable {
    public static let schema = "records"
    
    public final class IDValue: Fields, Hashable, @unchecked Sendable {
        @Parent(key: "meeting_id")
        public var meeting: Meeting
        
        @Field(key: "lang")
        public var lang: String
        
        public init() {}
        
        public convenience init(meeting: Meeting, lang: String) throws {
            try self.init(meetingId: meeting.requireID(), lang: lang)
        }

        public init(meetingId: Meeting.IDValue, lang: String) {
            self.$meeting.id = meetingId
            self.lang = lang
        }

        public static func == (lhs: IDValue, rhs: IDValue) -> Bool {
            lhs.$meeting.id == rhs.$meeting.id && lhs.lang == rhs.lang
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.$meeting.id)
            hasher.combine(self.lang)
        }
        
    }
    
    @CompositeID()
    public var id: IDValue?

    @Field(key: "user_id")
    public var userId: UUID // TODO: userId: UUID durch user: User austauschen

    @Field(key: "status")
    public var status: RecordStatus

    @Field(key: "content")
    public var content: String

    public init() { }
    
    public init(id: IDValue, userId: UUID, status: RecordStatus, content: String) {
        self.id = id
        self.userId = userId
        self.status = status
        self.content = content
    }
}

public enum RecordStatus: String, Codable, @unchecked Sendable {
    case underway
    case submitted
    case approved
}
