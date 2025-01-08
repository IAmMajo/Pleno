import Fluent
import Models

struct CreateSpecialRide: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(SpecialRide.schema)
            .id()
            .field("user_id", .uuid, .required, .references(User.schema, "id"))
            .field("name", .string, .required)
            .field("description", .string)
            .field("vehicle_description", .string)
            .field("starts", .datetime, .required)
            .field("ends", .datetime, .required)
            .field("start_latitude", .float, .required)
            .field("start_longitude", .float, .required)
            .field("destination_latitude", .float, .required)
            .field("destination_longitude", .float, .required)
            .field("emptySeats", .uint8, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(SpecialRide.schema).delete()
    }
}


