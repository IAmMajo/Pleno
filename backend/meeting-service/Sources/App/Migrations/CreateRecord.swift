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
            .field("meeting_id", .uuid, .required, .references(Meeting.schema, .id))
            .field("lang", .string, .required)
            .field("identity_id", .uuid, .required) // TODO: Notwendigkeit von .references überprüfen. Zu 'identities' oder 'attendances'?
            .field("status", recordStatus)
            .field("content", .string, .required, .sql(.default("")))
            .compositeIdentifier(over: "meeting_id", "lang")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Record.schema).delete()
    }
}
