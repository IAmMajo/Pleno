import Fluent
import Foundation
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class Poll: Model, @unchecked Sendable {
    public static let schema = "polls"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "question")
    public var question: String
    
    @Field(key: "description")
    public var description: String
    
    @Timestamp(key: "started_at", on: .create)
    public var startedAt: Date?
    
    @Field(key: "closed_at")
    public var closedAt: Date
    
    @Field(key: "anonymous")
    public var anonymous: Bool
    
    @Field(key: "multi_select")
    public var multiSelect: Bool
    
    @Children(for: \.$id.$poll)
    public var votingOptions: [PollVotingOption]

    public init() { }
    
    public init(
        id: UUID? = nil,
        question: String,
        description: String,
        closedAt: Date,
        anonymous: Bool,
        multiSelect: Bool
    ) {
        self.id = id
        self.question = question
        self.description = description
        self.closedAt = closedAt
        self.anonymous = anonymous
        self.multiSelect = multiSelect
    }
}
