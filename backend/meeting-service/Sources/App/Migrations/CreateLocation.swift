import Fluent
import FluentSQL
import Models

struct CreateLocation: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Location.schema)
            .id()
            .field("name", .string, .required)
            .field("street", .string, .required, .sql(.default("")))
            .field("number", .string, .required, .sql(.default("")))
            .field("letter", .string, .required, .sql(.default("")))
            .field("place_id", .uuid, .required, .references(Place.schema, .id))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Location.schema).delete()
    }
}
