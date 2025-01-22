import Fluent
import FluentSQL
import Models

struct CreatePollVote: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(PollVote.schema)
            .field("poll_voting_option_poll_id", .uuid, .required)
            .field("poll_voting_option_index", .uint8, .required)
            .field("identity_id", .uuid, .required, .references(Identity.schema, .id))
            .foreignKey(["poll_voting_option_poll_id", "poll_voting_option_index"], references: PollVotingOption.schema, ["poll_id", "index"], onDelete: .cascade)
            .compositeIdentifier(over: "poll_voting_option_poll_id", "poll_voting_option_index", "identity_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(PollVote.schema).delete()
    }
}
