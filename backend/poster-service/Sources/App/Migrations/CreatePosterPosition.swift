import Fluent
import Models

struct CreatePosterPositions: AsyncMigration {

    func prepare(on database: Database) async throws {
        try await database.schema(PosterPosition.schema)
            .id()
            .field("poster_id", .uuid, .references(Poster.schema , .id, onDelete: .cascade))
            .field("latitude", .double, .required)
            .field("longitude", .double, .required)
            .field("posted_at", .datetime)
            .field("posted_by", .uuid,  .references(Identity.schema , .id))
            .field("expires_at", .datetime , .required )
            .field("removed_at", .datetime)
            .field("removed_by", .uuid,  .references(Identity.schema , .id)) 
            .field("image", .data)
            .field("damaged", .bool)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(PosterPosition.schema).delete()
    }
}
