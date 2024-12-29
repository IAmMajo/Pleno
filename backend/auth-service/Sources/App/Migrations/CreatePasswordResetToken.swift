import Fluent
import Models

struct CreatePasswordResetToken: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(PasswordResetToken.schema)
            .id()
            .field("user_id", .uuid, .references(User.schema, "id", onDelete: .setNull))
            .field("token", .string)
            .field("expires_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(PasswordResetToken.schema).delete()
    }
}


