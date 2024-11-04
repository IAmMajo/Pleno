//
//  services.swift
//  config-service
//
//  Created by Dennis Sept on 02.11.24.
//

import Fluent

struct CreateService: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("services")
            .id() 
            .field("name", .string, .required) 
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("services").delete() 
    }
}
