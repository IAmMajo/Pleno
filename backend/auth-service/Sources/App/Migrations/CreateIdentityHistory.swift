import Fluent
import Models

struct CreateIdentityHistory: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(IdentityHistory.schema)
            .id()
            .field("user_id", .uuid, .references(User.schema, "id", onDelete: .setNull))
            .field("identity_id", .uuid, .required, .references(Identity.schema, "id"))
            .field("valid_from", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(IdentityHistory.schema).delete()
    }
}
