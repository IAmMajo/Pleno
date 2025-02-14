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

struct CreateAttendance: AsyncMigration {
    func prepare(on database: Database) async throws {
        let attendanceStatus = try await database.enum("attendance_status")
            .case("present")
            .case("absent")
            .case("accepted")
            .create()
        try await database.schema(Attendance.schema)
            .field("meeting_id", .uuid, .required, .references(Meeting.schema, .id, onDelete: .cascade))
            .field("identity_id", .uuid, .required, .references(Identity.schema, .id, onDelete: .cascade))
            .field("status", attendanceStatus)
            .compositeIdentifier(over: "meeting_id", "identity_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Attendance.schema).delete()
        try await database.enum("attendance_status").delete()
    }
}
