// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
        
        @Parent(key: "identity_id")
        public var identity: Identity
        
        public init() {}
        
        public convenience init(meeting: Meeting, identity: Identity) throws {
            try self.init(meetingId: meeting.requireID(), identityId: identity.requireID())
        }
        
        public convenience init(meetingId: Meeting.IDValue, identity: Identity) throws {
            try self.init(meetingId: meetingId, identityId: identity.requireID())
        }
        
        public convenience init(meeting: Meeting, identityId: Identity.IDValue) throws {
            try self.init(meetingId: meeting.requireID(), identityId: identityId)
        }

        public init(meetingId: Meeting.IDValue, identityId: Identity.IDValue) {
            self.$meeting.id = meetingId
            self.$identity.id = identityId
        }

        public static func == (lhs: IDValue, rhs: IDValue) -> Bool {
            lhs.$meeting.id == rhs.$meeting.id && lhs.$identity.id == rhs.$identity.id
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.$meeting.id)
            hasher.combine(self.$identity.id)
        }
        
    }
    
    @CompositeID()
    public var id: IDValue?

    @Enum(key: "status")
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
