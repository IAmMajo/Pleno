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
import Models

struct CreateRecord: AsyncMigration {
    func prepare(on database: Database) async throws {
        let recordStatus = try await database.enum("record_status")
            .case("underway")
            .case("submitted")
            .case("approved")
            .create()
        try await database.schema(Record.schema)
            .field("meeting_id", .uuid, .required, .references(Meeting.schema, .id, onDelete: .cascade))
            .field("lang", .string, .required)
            .field("identity_id", .uuid, .required, .references(Identity.schema, .id, onDelete: .cascade))
            .field("status", recordStatus, .required, .sql(.default("underway")))
            .field("content", .string, .required, .sql(.default("")))
            .compositeIdentifier(over: "meeting_id", "lang")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Record.schema).delete()
        try await database.enum("record_status").delete()
    }
}
