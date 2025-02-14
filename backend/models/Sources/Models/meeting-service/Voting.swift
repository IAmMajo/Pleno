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
