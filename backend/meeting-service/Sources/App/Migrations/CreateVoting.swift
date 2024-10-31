import Fluent
import FluentSQL

struct CreateVoting: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Voting.schema)
            .id()
            .field("meeting_id", .uuid, .required, .references(Meeting.schema, "id"))
            .field("question", .string, .required)
            .field("is_closed", .bool, .required)
            .field("content", .string, .required, .sql(.default("")))
            .field("started_at", .datetime/*, .required, .sql(.default(SQLFunction("now")))*/)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Voting.schema).delete()
    }
}
