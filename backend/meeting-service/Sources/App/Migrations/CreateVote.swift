import Fluent
import FluentSQL

struct CreateVote: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Vote.schema)
            .field("voting_id", .uuid, .required, .references(Voting.schema, "id")) // TODO: .references(Voting.schema, "id") oder .references(VotingOption.schema, "id")
            .field("user_id", .uuid, .required) // TODO: Notwendigkeit von .references überprüfen. Zu 'users' oder 'attendances'?
            .field("index", .uint8, .required)
            .compositeIdentifier(over: "voting_id", "user_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Vote.schema).delete()
    }
}
