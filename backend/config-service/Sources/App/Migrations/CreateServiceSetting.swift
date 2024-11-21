//
//  service_settings.swift
//  config-service
//
//  Created by Dennis Sept on 02.11.24.
//
import Fluent
import Models

struct CreateServiceSetting: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("service_settings")
            .id() 
            .field("service_id", .uuid, .required, .references(Service.schema, .id))
            .field("setting_id", .uuid, .required, .references(Setting.schema, .id))
            .field("created", .datetime)
            .field("updated", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("service_settings").delete()
    }
}
