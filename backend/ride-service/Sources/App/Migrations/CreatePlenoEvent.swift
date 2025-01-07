import Fluent
import Models

struct CreatePlenoEvent: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(PlenoEvent.schema)
            .id()
            .field("name", .string, .required)
            .field("description", .string)
            .field("starts", .datetime, .required)
            .field("ends", .datetime, .required)
            .field("latitude", .float, .required)
            .field("longitude", .float, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(PlenoEvent.schema).delete()
    }
}
