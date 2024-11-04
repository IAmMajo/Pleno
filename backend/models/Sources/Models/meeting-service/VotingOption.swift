import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class VotingOption: Model, @unchecked Sendable {
    public static let schema = "voting_options"
    
    public final class IDValue: Fields, Hashable, @unchecked Sendable {
        @Parent(key: "voting_id")
        public var voting: Voting
        
        @Field(key: "index")
        public var index: UInt8
        
        public init() {}
        
        public convenience init(voting: Voting, index: UInt8) throws {
            try self.init(votingId: voting.requireID(), index: index)
        }

        public init(votingId: Voting.IDValue, index: UInt8) {
            self.$voting.id = votingId
            self.index = index
        }

        public static func == (lhs: IDValue, rhs: IDValue) -> Bool {
            lhs.$voting.id == rhs.$voting.id && lhs.index == rhs.index
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.$voting.id)
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
