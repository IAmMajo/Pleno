import Fluent
import Models

struct CreateEventRideRequest: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(EventRideRequest.schema)
            .id()
            .field("event_ride_id", .uuid, .required, .references(EventRide.schema, "id", onDelete: .cascade))
            .field("interested_party_id", .uuid, .required, .references(EventRideInteresedParty.schema, "id", onDelete: .cascade))
            .field("accepted", .bool, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(EventRideRequest.schema).delete()
    }
}
