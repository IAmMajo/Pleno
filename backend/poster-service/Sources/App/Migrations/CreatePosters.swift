import Fluent
import Models

struct CreatePosters: AsyncMigration {

    func prepare(on database: Database) async throws {
        try await database.schema(Poster.schema)
            .id()
            .field("name", .string, .required)
            .field("description", .string)
            .field("image", .data, .required) 
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Poster.schema).delete()
    }
}
