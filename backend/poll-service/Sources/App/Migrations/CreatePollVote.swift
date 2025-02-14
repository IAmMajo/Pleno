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
import FluentSQL
import Models

struct CreatePollVote: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(PollVote.schema)
            .field("poll_voting_option_poll_id", .uuid, .required)
            .field("poll_voting_option_index", .uint8, .required)
            .field("identity_id", .uuid, .required, .references(Identity.schema, .id))
            .foreignKey(["poll_voting_option_poll_id", "poll_voting_option_index"], references: PollVotingOption.schema, ["poll_id", "index"], onDelete: .cascade)
            .compositeIdentifier(over: "poll_voting_option_poll_id", "poll_voting_option_index", "identity_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(PollVote.schema).delete()
    }
}
