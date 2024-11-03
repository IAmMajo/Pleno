import Fluent
import FluentSQL

struct CreatePlace: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Place.schema)
            .id()
            .field("postal_code", .string, .required)
            .field("place", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Place.schema).delete()
    }
}
