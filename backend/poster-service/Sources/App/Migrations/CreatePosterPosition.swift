//
//  CreatePosterPosition.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//

import Fluent
import Models

struct CreatePosterPositions: AsyncMigration {
    // Erstellt die Tabelle "poster_positions"
    func prepare(on database: Database) async throws {
        try await database.schema(PosterPosition.schema)
            .id() // Automatisches UUID-Primärschlüsselfeld
            .field("poster_id", .uuid, .references(Poster.schema , .id)) // Foreign Key zu Posters
            .field("latitude", .double, .required) // Latitude als Pflichtfeld
            .field("longitude", .double, .required) // Longitude als Pflichtfeld
            .field("posted_by", .uuid,  .references(Identity.schema , .id)) // Foreign Key zu Identity
            .field("expires_at", .datetime , .required )
            .field("removed_at", .datetime)
            .field("removed_by", .uuid,  .references(Identity.schema , .id)) // Foreign Key zu Identity
            .field("image_url", .string )
            .create()
    }

    // Löscht die Tabelle "poster_positions", falls nötig
    func revert(on database: Database) async throws {
        try await database.schema(PosterPosition.schema).delete()
    }
}
