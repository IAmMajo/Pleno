import Fluent

struct CreateFool: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Fool.schema)
            .id()
            .field("victim_id", .uuid, .required, .references(Victim.schema, "id"))
            .field("fooled_at", .datetime, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Fool.schema).delete()
    }
}
