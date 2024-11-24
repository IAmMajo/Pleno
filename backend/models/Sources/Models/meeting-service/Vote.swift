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
        
        @Parent(key: "identity_id")
        public var identity: Identity
        
        public init() {}
        
        public convenience init(voting: Voting, identity: Identity) throws {
            try self.init(votingId: voting.requireID(), identityId: identity.requireID())
        }

        public init(votingId: Voting.IDValue, identityId: Identity.IDValue) {
            self.$voting.id = votingId
            self.$identity.id = identityId
        }

        public static func == (lhs: IDValue, rhs: IDValue) -> Bool {
            lhs.$voting.id == rhs.$voting.id && lhs.$identity.id == rhs.$identity.id
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.$voting.id)
            hasher.combine(self.$identity.id)
        }
        
    }
    
    @CompositeID()
    public var id: IDValue?
    
    @Field(key: "index") // Index 0: Abstention
    public var index: UInt8
    
    public init() { }
    
    public init(id: IDValue, index: UInt8) {
        self.id = id
        self.index = index
    }
}
