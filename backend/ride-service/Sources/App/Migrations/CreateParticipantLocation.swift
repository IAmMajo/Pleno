import Fluent
import Models

struct CreateParticipantLocation: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(ParticipantLocation.schema)
            .id()
            .field("user_id", .uuid, .required, .references(User.schema, "id"))
            .field("description", .string)
            .field("latitude", .float, .required)
            .field("longitude", .float, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(ParticipantLocation.schema).delete()
    }
}

