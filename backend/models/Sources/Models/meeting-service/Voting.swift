import Fluent
import Foundation
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class Voting: Model, @unchecked Sendable {
    public static let schema = "votings"
    
    @ID(key: .id)
    public var id: UUID?

    @Parent(key: "meeting_id")
    public var meeting: Meeting
    
    @Field(key: "question")
    public var question: String
    
    @Field(key: "description")
    public var description: String
    
    @Field(key: "is_open")
    public var isOpen: Bool
    
//    @Timestamp(key: "started_at", on: .create) // in minutes
    @OptionalField(key: "started_at") // in minutes, null = not started yet
    public var startedAt: Date?
    
    @OptionalField(key: "closed_at") // in minutes, null = not finished yet
    public var closedAt: Date?
    
    @Field(key: "anonymous")
    public var anonymous: Bool
    
    @Children(for: \.$id.$voting)
    public var votingOptions: [VotingOption]
    
    @Children(for: \.$id.$voting)
    public var votes: [Vote]

    public init() { }
    
    public init(
        id: UUID? = nil,
        meetingId: Meeting.IDValue,
        description: String,
        question: String,
        isOpen: Bool = false,
        anonymous: Bool
    ) {
        self.id = id
        self.$meeting.id = meetingId
        self.description = description
        self.question = question
        self.isOpen = isOpen
        self.anonymous = anonymous
    }
}
