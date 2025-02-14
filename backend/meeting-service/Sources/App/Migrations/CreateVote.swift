import Fluent
import FluentSQL
import Models

struct CreateVote: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Vote.schema)
            .field("voting_id", .uuid, .required, .references(Voting.schema, .id, onDelete: .cascade))
            .field("identity_id", .uuid, .required, .references(Identity.schema, .id))
            .field("index", .uint8, .required)
            .compositeIdentifier(over: "voting_id", "identity_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Vote.schema).delete()
    }
}
