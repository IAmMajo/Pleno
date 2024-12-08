import Fluent
import Models
import Vapor



struct CreateServiceSetting: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("service_settings")
            .id()
            .field("service_id", .uuid, .required, .references(Service.schema, .id))
            .field("setting_id", .uuid, .required, .references(Setting.schema, .id))
            .field("created", .datetime)
            .field("updated", .datetime)
            .create()
        
        // Services und Einstellungen laden
        guard let authService = try await Service.query(on: database)
                .filter(\.$name == "Auth-Service")
                .first(),
              let posterService = try await Service.query(on: database)
                .filter(\.$name == "Poster-Service")
                .first(),
              let registrationEnabledSetting = try await Setting.query(on: database)
                .filter(\.$key == "registration_enabled")
                .first(),
              let posterReminderSetting = try await Setting.query(on: database)
                .filter(\.$key == "poster_reminder_interval")
                .first(),
              let posterToBeTakenDownSetting = try await Setting.query(on: database)
                .filter(\.$key == "poster_to_be_taken_down_interval")
                .first(),
              let posterDeletionIntervalSetting = try await Setting.query(on: database)
                .filter(\.$key == "poster_deletion_interval")
                .first() else {
            throw Abort(.internalServerError, reason: "Fehler beim Laden der Services oder Einstellungen.")
        }

        // Initiale Zuordnungen erstellen
        let serviceSettings = [
            ServiceSetting(serviceID: try authService.requireID(), settingID: try registrationEnabledSetting.requireID()),
            ServiceSetting(serviceID: try posterService.requireID(), settingID: try posterDeletionIntervalSetting.requireID()),
            ServiceSetting(serviceID: try posterService.requireID(), settingID: try posterToBeTakenDownSetting.requireID()),
            ServiceSetting(serviceID: try posterService.requireID(), settingID: try posterReminderSetting.requireID())
        ]

        for serviceSetting in serviceSettings {
            try await serviceSetting.save(on: database)
        }
    }

    func revert(on database: Database) async throws {
        try await database.schema("service_settings").delete()
    }
}

