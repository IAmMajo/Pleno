//
//  CreatePosters.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//

import Fluent
import Models

struct CreatePosters: AsyncMigration {
    // Erstellt die Tabelle "posters"
    func prepare(on database: Database) async throws {
        try await database.schema(Poster.schema)
            .id() // Automatisches UUID-Primärschlüsselfeld
            .field("name", .string, .required) // Name als Pflichtfeld
            .field("description", .string) // Optionales Beschreibungsfeld
            .field("image", .data, .required) // Bild-URL als Pflichtfeld
            .create()
    }

    // Löscht die Tabelle "posters", falls nötig
    func revert(on database: Database) async throws {
        try await database.schema(Poster.schema).delete()
    }
}
