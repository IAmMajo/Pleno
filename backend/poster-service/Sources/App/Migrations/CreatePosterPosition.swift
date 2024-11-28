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
            .field("poster_id", .uuid, .required, .references(Poster.schema , .id)) // Foreign Key zu Posters
            .field("responsible_user_id", .uuid, .required, .references(User.schema, .id)) // Foreign Key zu Users
            .field("latitude", .double, .required) // Latitude als Pflichtfeld
            .field("longitude", .double, .required) // Longitude als Pflichtfeld
            .field("is_Displayed", .bool, .required) // Anzeige-Status als Pflichtfeld
            .field("posted_at", .datetime)
            .field("expires_at", .datetime)
            .field("image_url", .string , .required)
            .create()
    }

    // Löscht die Tabelle "poster_positions", falls nötig
    func revert(on database: Database) async throws {
        try await database.schema(PosterPosition.schema).delete()
    }
}
