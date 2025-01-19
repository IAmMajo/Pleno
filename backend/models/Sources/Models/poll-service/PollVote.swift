import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class PollVote: Model, @unchecked Sendable {
    public static let schema = "poll_votes"
    
    public final class IDValue: Fields, Hashable, @unchecked Sendable {
        
        @CompositeParent(prefix: "poll_voting_option", strategy: .snakeCase)
        public var pollVotingOption: PollVotingOption
        
        @Parent(key: "identity_id")
        public var identity: Identity
        
        public init() {}
        
        public convenience init(poll: Poll, index: UInt8, identity: Identity) throws {
            try self.init(pollVotingOptionId: .init(pollId: poll.requireID(), index: index), identity: identity)
        }
        
        public convenience init(pollId: Poll.IDValue, index: UInt8, identity: Identity) throws {
            try self.init(pollVotingOptionId: .init(pollId: pollId, index: index), identity: identity)
        }
        
        public convenience init(poll: Poll, index: UInt8, identityId: Identity.IDValue) throws {
            try self.init(pollVotingOptionId: .init(pollId: poll.requireID(), index: index), identityId: identityId)
        }
        
        public convenience init(pollId: Poll.IDValue, index: UInt8, identityId: Identity.IDValue) {
            self.init(pollVotingOptionId: .init(pollId: pollId, index: index), identityId: identityId)
        }
        
        public convenience init(pollVotingOption: PollVotingOption, identity: Identity) throws {
            try self.init(pollVotingOptionId: pollVotingOption.requireID(), identityId: identity.requireID())
        }
        
        public convenience init(pollVotingOption: PollVotingOption, identityId: Identity.IDValue) throws {
            try self.init(pollVotingOptionId: pollVotingOption.requireID(), identityId: identityId)
        }
        
        public convenience init(pollVotingOptionId: PollVotingOption.IDValue, identity: Identity) throws {
            try self.init(pollVotingOptionId: pollVotingOptionId, identityId: identity.requireID())
        }
        
        public init(pollVotingOptionId: PollVotingOption.IDValue, identityId: Identity.IDValue) {
            self.$pollVotingOption.id = pollVotingOptionId
            self.$identity.id = identityId
        }
        
        public static func == (lhs: IDValue, rhs: IDValue) -> Bool {
            lhs.$pollVotingOption.id == rhs.$pollVotingOption.id &&
            lhs.$identity.id == rhs.$identity.id
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.$pollVotingOption.id)
            hasher.combine(self.$identity.id)
        }
        
    }
    
    @CompositeID()
    public var id: IDValue?
    
    public init() { }
    
    public init(id: IDValue) {
        self.id = id
    }
}
