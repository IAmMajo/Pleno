import Fluent
import Models

struct CreateEmailVerification: AsyncMigration {
    func prepare(on database: Database) async throws {
        let verificationStatus = try await database.enum("verification_status")
                    .case("failed")
                    .case("pending")
                    .case("verified")
                    .create()

        try await database.schema(EmailVerification.schema)
            .field("email", .string, .identifier(auto: false))
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("code", .string, .required)
            .field("status", verificationStatus)
            .field("expires_at", .datetime)
            .field("created_at", .datetime, .required, .custom("DEFAULT CURRENT_TIMESTAMP"))
            .field("verified_at", .datetime)
            .unique(on: "user_id")
            .unique(on: "email")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(EmailVerification.schema).delete()
        try await database.enum("verification_status").delete()
    }
}

