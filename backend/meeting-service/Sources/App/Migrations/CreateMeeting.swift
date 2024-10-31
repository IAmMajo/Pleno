import Fluent

struct CreateMeeting: AsyncMigration {
    func prepare(on database: Database) async throws {
        let meetingStatus = try await database.enum("meeting_status")
            .case("scheduled")
            .case("in_session")
            .case("completed")
            .create()
        try await database.schema(Meeting.schema)
            .id()
            .field("name", .string, .required)
            .field("description", .string, .required, .sql(.default("")))
            .field("status", meetingStatus, .required, .sql(.default("scheduled")))
            .field("start", .datetime, .required)
            .field("duration", .uint16)
            .field("location", .string)
            .field("chair_id", .uuid, .required) // TODO: Notwendigkeit von .references überprüfen. Zu 'users' oder 'attendances'?
            .field("code", .string)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Meeting.schema).delete()
    }
}
