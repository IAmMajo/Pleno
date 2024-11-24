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
    
    @Field(key: "status")
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
