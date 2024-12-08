import Fluent

struct CreateVictim: AsyncMigration {
    func prepare(on database: Database) async throws {
        let experiment = try await database.enum("experiment")
            .case("weihnachtsmarkt")
            .case("mensa")
            .case("briefkasten")
            .create()
        try await database.schema(Victim.schema)
            .id()
            .field("count", .uint8, .required)
            .field("status", experiment, .required)
            .field("unused", .bool, .required, .sql(.default(false)))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Victim.schema).delete()
        try await database.enum("experiment").delete()
    }
}
