import Fluent
import Models

struct CreateRide: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Ride.schema)
            .id()
            .field("name", .string, .required)
            .field("description", .string)
            .field("starts", .datetime, .required)
            .field("latitude", .float, .required)
            .field("longitude", .float, .required)
            .field("organizer_id", .uuid, .required, .references(User.schema, "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Ride.schema).delete()
    }
}

