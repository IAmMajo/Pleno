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
import Foundation
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class Meeting: Model, @unchecked Sendable {
    public static let schema = "meetings"
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "name")
    public var name: String
    
    @Field(key: "description")
    public var description: String
    
    @Enum(key: "status")
    public var status: MeetingStatus
    
    @Field(key: "start")
    public var start: Date
    
    @Field(key: "duration") // in minutes
    public var duration: UInt16?
    
    @OptionalParent(key: "location_id")
    public var location: Location?
    
    @OptionalParent(key: "chair_id")
    public var chair: Identity?
    
    @OptionalField(key: "code") // 6-digit code
    public var code: String?
    
    @Children(for: \.$id.$meeting)
    public var attendances: [Attendance]
    
    @Children(for: \.$id.$meeting)
    public var records: [Record]
    
    @Children(for: \.$meeting)
    public var votings: [Voting]

    public init() { }
    
    public init(
    id: UUID? = nil,
    name: String,
    description: String = "",
    status: MeetingStatus,
    start: Date,
    duration: UInt16? = nil,
    locationId: Location.IDValue? = nil,
    chairId: Identity.IDValue? = nil,
    code: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.status = status
        self.start = start
        self.duration = duration
        self.$location.id = locationId
        self.$chair.id = chairId
        self.code = code
    }
}

public enum MeetingStatus: String, Codable, @unchecked Sendable {
    case scheduled
    case inSession
    case completed
}
