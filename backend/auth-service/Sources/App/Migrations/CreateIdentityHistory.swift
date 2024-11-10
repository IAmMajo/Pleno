import Fluent
import Models

struct CreateIdentityHistory: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(IdentityHistory.schema)
            .id()
            .field("name", .string, .required)
            .field("user_id", .uuid, .required, .references(User.schema, "id"))
            .field("identity_id", .uuid, .required, .references(Identity.schema, "id"))
            .field("valid_from", .date)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(IdentityHistory.schema).delete()
    }
}
