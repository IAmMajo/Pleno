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
