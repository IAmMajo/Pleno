//
//  settings.swift
//  config-service
//
//  Created by Dennis Sept on 02.11.24.
//

import Fluent

struct CreateSetting: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("settings")
            .id()
            .field("key", .string, .required)
            .field("value", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("settings").delete() 
    }
}
