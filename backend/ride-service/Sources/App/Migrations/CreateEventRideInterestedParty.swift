import Fluent
import Models

struct CreateEventRideInterestedParty: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(EventRideInterestedParty.schema)
            .id()
            .field("participant_id", .uuid, .required, .references(EventParticipant.schema, "id", onDelete: .cascade))
            .field("latitude", .float, .required)
            .field("longitude", .float, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(EventRideInterestedParty.schema).delete()
    }
}
