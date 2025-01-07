import Fluent
import Models

struct CreateSpecialRideRequest: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(SpecialRideRequest.schema)
            .id()
            .field("user_id", .uuid, .required, .references(User.schema, "id"))
            .field("special_ride_id", .uuid, .required, .references(SpecialRide.schema, "id"))
            .field("accepted", .bool, .required)
            .field("latitude", .float, .required)
            .field("longitude", .float, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(SpecialRideRequest.schema).delete()
    }
}
