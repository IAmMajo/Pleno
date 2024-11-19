//
//  service_settings.swift
//  config-service
//
//  Created by Dennis Sept on 02.11.24.
//
import Fluent

struct CreateServiceSetting: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("service_settings")
            .id() 
            .field("service_id", .uuid, .required, .references("service", "id"))
            .field("settings_id", .uuid, .required, .references("settings", "id"))
            .field("created", .datetime, .required)
            .field("updated", .datetime , .required)
            .unique(on: "service_id", "setting_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("service_settings").delete()
    }
}
