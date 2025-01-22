import Fluent
import FluentSQL
import Models

struct CreatePollVotingOption: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(PollVotingOption.schema)
            .field("poll_id", .uuid, .required, .references(Poll.schema, .id, onDelete: .cascade))
            .field("index", .uint8, .required)
            .field("text", .string, .required)
            .compositeIdentifier(over: "poll_id", "index")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(PollVotingOption.schema).delete()
    }
}
