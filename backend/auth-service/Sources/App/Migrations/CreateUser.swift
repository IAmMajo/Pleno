import Fluent
import Models

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(User.schema)
            .id()
            .field("idenity_id", .uuid, .required, .references(Identity.schema, "id"))
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("is_admin", .bool, .required)
            .field("is_active", .bool, .required)
            .field("created_at", .date)
            .field("updated_at", .date)
            .field("last_login", .date)
            .unique(on: "email")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(User.schema).delete()
    }
}
