import Fluent

struct CreateVictim: AsyncMigration {
    func prepare(on database: Database) async throws {
        let experiment = try await database.enum("experiment")
            .case("labyrinth")
            .case("briefkasten")
            .create()
        try await database.schema(Victim.schema)
            .id()
            .field("experiment", experiment, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Victim.schema).delete()
        try await database.enum("experiment").delete()
    }
}
