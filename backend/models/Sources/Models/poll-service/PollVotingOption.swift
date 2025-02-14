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
    
    @CompositeChildren(for: \PollVote.$id.$pollVotingOption)
    public var votes: [PollVote]
    
    public init() { }
    
    public init(id: IDValue, text: String) {
        self.id = id
        self.text = text
    }
}
