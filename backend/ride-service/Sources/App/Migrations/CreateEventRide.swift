import Fluent
import Models

struct CreateEventRide: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(EventRide.schema)
            .id()
            .field("event_id", .uuid, .required, .references(PlenoEvent.schema, "id"))
            .field("participant_id", .uuid, .required, .references(EventParticipant.schema, "id"))
            .field("starts", .datetime, .required)
            .field("latitude", .float, .required)
            .field("longitude", .float, .required)
            .field("emptySeats", .uint8, .required)
            .field("description", .string)
            .field("vehicle_description", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(EventRide.schema).delete()
    }
}

