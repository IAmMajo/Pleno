import Fluent
import Models

struct CreateParticipant: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Participant.schema)
            .id()
            .field("ride_id", .uuid, .required, .references(Ride.schema, "id"))
            .field("user_id", .uuid, .required, .references(User.schema, "id"))
            .field("driver", .bool, .required)
            .field("passengers_count", .int)
            .field("latitude", .float, .required)
            .field("longitude", .float, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Participant.schema).delete()
    }
}

