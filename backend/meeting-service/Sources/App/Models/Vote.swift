import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class Vote: Model, @unchecked Sendable {
    public static let schema = "votes"
    
    public final class IDValue: Fields, Hashable, @unchecked Sendable {
        @Parent(key: "voting_option_id")
        public var votingOption: VotingOption
        
        @Field(key: "user_id")
        public var userId: UUID // TODO: userId: UUID durch user: User austauschen
        
        public init() {}
        
        public convenience init(voting: VotingOption, userId: UUID) throws {
            try self.init(votingId: voting.requireID(), userId: userId)
        }

        public init(votingId: VotingOption.IDValue, userId: UUID) {
            self.$votingOption.id = votingId
            self.userId = userId
        }

        public static func == (lhs: IDValue, rhs: IDValue) -> Bool {
            lhs.$votingOption.id == rhs.$votingOption.id && lhs.userId == rhs.userId
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.$votingOption.id)
            hasher.combine(self.userId)
        }
        
    }
    
    @CompositeID()
    public var id: IDValue?
    
    public init() { }
    
    public init(id: IDValue) {
        self.id = id
    }
}
