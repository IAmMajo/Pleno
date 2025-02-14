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
