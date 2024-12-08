import Fluent
import Models

struct CreateIdentity: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Identity.schema)
            .id()
            .field("name", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Identity.schema).delete()
    }
}
