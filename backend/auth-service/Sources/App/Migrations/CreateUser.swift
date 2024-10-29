import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("email", .string, .required)
            .field("name", .string, .required)
            .field("password_hash", .string, .required)
            .field("role", .string)
            .field("is_active", .bool, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}
