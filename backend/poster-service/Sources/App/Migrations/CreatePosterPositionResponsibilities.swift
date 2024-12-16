//
//  CreatePosterPositionResponsibilities.swift
//  poster-service
//
//  Created by Dennis Sept on 16.12.24.
//

import Fluent
import Models

struct CreatePosterPositionResponsibilities: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema(PosterPositionResponsibilities.schema)
            .id() // Automatisches UUID-Primärschlüsselfeld
            .field("user_id", .uuid, .required, .references(User.schema , .id)) // Foreign Key zu users
            .field("poster_position_id", .uuid, .required, .references(PosterPosition.schema, .id)) // Foreign Key zu poster_positions
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(PosterPositionResponsibilities.schema).delete()
    }
}
