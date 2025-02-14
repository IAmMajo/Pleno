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
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class Vote: Model, @unchecked Sendable {
    public static let schema = "votes"
    
    public final class IDValue: Fields, Hashable, @unchecked Sendable {
        @Parent(key: "voting_id")
        public var voting: Voting
        
        @Parent(key: "identity_id")
        public var identity: Identity
        
        public init() {}
        
        public convenience init(voting: Voting, identity: Identity) throws {
            try self.init(votingId: voting.requireID(), identityId: identity.requireID())
        }
        
        public convenience init(votingId: Voting.IDValue, identity: Identity) throws {
            try self.init(votingId: votingId, identityId: identity.requireID())
        }
        
        public convenience init(voting: Voting, identityId: Identity.IDValue) throws {
            try self.init(votingId: voting.requireID(), identityId: identityId)
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
