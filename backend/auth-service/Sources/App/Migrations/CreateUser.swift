import Fluent
import Models

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(User.schema)
            .id()
            .field("identity_id", .uuid, .required, .references(Identity.schema, "id"))
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("is_admin", .bool, .required)
            .field("is_active", .bool, .required)
            .field("profile_image", .data)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("last_login", .datetime)
            .field("is_notifications_active", .bool, .required)
            .field("is_push_notifications_active", .bool, .required)
            .unique(on: "email")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(User.schema).delete()
    }
}
