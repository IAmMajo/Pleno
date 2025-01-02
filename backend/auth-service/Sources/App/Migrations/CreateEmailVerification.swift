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
            .id()
            .field("user_id", .uuid, .required, .references(User.schema, "id"))
            .field("email", .string, .required)
            .field("code", .string, .required)
            .field("status", verificationStatus)
            .field("expires_at", .datetime)
            .field("created_at", .datetime, .required, .custom("DEFAULT CURRENT_TIMESTAMP"))
            .field("verified_at", .datetime)
            .unique(on: "code")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(EmailVerification.schema).delete()
        try await database.enum("verification_status").delete()
    }
}

