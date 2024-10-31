import Fluent

struct CreateAttendance: AsyncMigration {
    func prepare(on database: Database) async throws {
        let attendanceStatus = try await database.enum("attendance_status")
            .case("present")
            .case("absent")
            .case("accepted")
            .create()
        try await database.schema(Attendance.schema)
            .field("meeting_id", .uuid, .required, .references(Meeting.schema, "id"))
            .field("user_id", .uuid, .required) // TODO: Notwendigkeit von .references zu 'users' überprüfen.
            .field("name", .string, .required)
            .field("status", attendanceStatus)
            .compositeIdentifier(over: "meeting_id", "user_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Attendance.schema).delete()
    }
}
