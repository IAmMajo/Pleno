import Fluent
import FluentSQL
import Models

struct CreatePoll: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Poll.schema)
            .id()
            .field("question", .string, .required)
            .field("description", .string, .required, .sql(.default("")))
            .field("started_at", .datetime, .required, .sql(.default(SQLFunction("now"))))
            .field("closed_at", .datetime, .required)
            .field("anonymous", .bool, .required)
            .field("multi_select", .bool, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Poll.schema).delete()
    }
}
