import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class Vote: Model, @unchecked Sendable {
    public static let schema = "votes"
    
    public final class IDValue: Fields, Hashable, @unchecked Sendable {
//        @Field(key: "voting_id")
//        public var votingId: UUID // TODO: Ggf. überdenken, ob ein (Optional)CompositeParent sinnvoller wäre
        @Parent(key: "voting_id")
        public var voting: Voting
        
        @Field(key: "identity_id")
        public var identityId: UUID // TODO: identityId: UUID durch identity: Identity austauschen
        
        public init() {}
        
        public convenience init(voting: Voting, identityId: UUID) throws {
            try self.init(votingId: voting.requireID(), identityId: identityId)
        }

        public init(votingId: Voting.IDValue, identityId: UUID) {
            self.$voting.id = votingId
            self.identityId = identityId
        }

        public static func == (lhs: IDValue, rhs: IDValue) -> Bool {
            lhs.$voting.id == rhs.$voting.id && lhs.identityId == rhs.identityId
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.$voting.id)
            hasher.combine(self.identityId)
        }
        
    }
    
    @CompositeID()
    public var id: IDValue?
    
    @OptionalField(key: "index")
    public var index: UInt8?
    
    public init() { }
    
    public init(id: IDValue) {
        self.id = id
    }
}
