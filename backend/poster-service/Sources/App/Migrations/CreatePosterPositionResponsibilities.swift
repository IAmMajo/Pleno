import Fluent
import Models

struct CreatePosterPositionResponsibilities: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema(PosterPositionResponsibilities.schema)
            .id()
            .field("user_id", .uuid, .required, .references(User.schema , .id, onDelete: .cascade))
            .field("poster_position_id", .uuid, .required, .references(PosterPosition.schema, .id, onDelete: .cascade) ) 
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(PosterPositionResponsibilities.schema).delete()
    }
}
