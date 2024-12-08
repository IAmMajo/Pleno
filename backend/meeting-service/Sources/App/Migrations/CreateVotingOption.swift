import Fluent
import FluentSQL
import Models

struct CreateVotingOption: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(VotingOption.schema)
            .field("voting_id", .uuid, .required, .references(Voting.schema, .id, onDelete: .cascade))
            .field("index", .uint8, .required)
            .field("text", .string, .required)
            .compositeIdentifier(over: "voting_id", "index")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(VotingOption.schema).delete()
    }
}
