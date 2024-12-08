import Fluent
import FluentSQL
import Models

struct CreateVoting: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Voting.schema)
            .id()
            .field("meeting_id", .uuid, .required, .references(Meeting.schema, .id))
            .field("question", .string, .required)
            .field("description", .string, .required, .sql(.default("")))
            .field("is_open", .bool, .required, .sql(.default(false)))
            .field("content", .string, .required, .sql(.default("")))
            .field("started_at", .datetime/*, .required, .sql(.default(SQLFunction("now")))*/)
            .field("closed_at", .datetime/*, .required*/)
            .field("anonymous", .bool, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Voting.schema).delete()
    }
}
