import Fluent
import Models

struct CreateEventParticipant: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(EventParticipant.schema)
            .id()
            .field("event_id", .uuid, .required, .references(PlenoEvent.schema, "id"))
            .field("user_id", .uuid, .required, .references(User.schema, "id"))
            .field("participates", .bool, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(EventParticipant.schema).delete()
    }
}
