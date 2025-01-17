import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class PollVotingOption: Model, @unchecked Sendable {
    public static let schema = "poll_voting_options"
    
    public final class IDValue: Fields, Hashable, @unchecked Sendable {
        @Parent(key: "poll_id")
        public var poll: Poll
        
        @Field(key: "index")
        public var index: UInt8
        
        public init() {}
        
        public convenience init(poll: Poll, index: UInt8) throws {
            try self.init(pollId: poll.requireID(), index: index)
        }

        public init(pollId: Poll.IDValue, index: UInt8) {
            self.$poll.id = pollId
            self.index = index
        }

        public static func == (lhs: IDValue, rhs: IDValue) -> Bool {
            lhs.$poll.id == rhs.$poll.id && lhs.index == rhs.index
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.$poll.id)
            hasher.combine(self.index)
        }
        
    }
    
    @CompositeID()
    public var id: IDValue?

    @Field(key: "text")
    public var text: String
    
    public init() { }
    
    public init(id: IDValue, text: String) {
        self.id = id
        self.text = text
    }
}
