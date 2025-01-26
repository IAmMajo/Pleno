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
        
        // Auth-Service laden
        guard let authService = try await Service.query(on: database)
            .filter(\.$name == "Auth-Service")
            .first() else {
                throw Abort(.internalServerError, reason: "Auth-Service konnte nicht geladen werden.")
        }

        // Poster-Service laden
        guard let posterService = try await Service.query(on: database)
            .filter(\.$name == "Poster-Service")
            .first() else {
                throw Abort(.internalServerError, reason: "Poster-Service konnte nicht geladen werden.")
        }

        // Meeting-Service laden
        guard let meetingService = try await Service.query(on: database)
            .filter(\.$name == "Meeting-Service")
            .first() else {
                throw Abort(.internalServerError, reason: "Meeting-Service konnte nicht geladen werden.")
        }

        // Einstellungen laden
        guard let isRegistrationEnabled = try await Setting.query(on: database)
            .filter(\.$key == "isRegistrationEnabled")
            .first() else {
                throw Abort(.internalServerError, reason: "Einstellung 'isRegistrationDisabled' konnte nicht geladen werden.")
        }

        guard let defaultLanguage = try await Setting.query(on: database)
            .filter(\.$key == "defaultLanguage")
            .first() else {
                throw Abort(.internalServerError, reason: "Einstellung 'defaultLanguage' konnte nicht geladen werden.")
        }

        guard let posterReminderSetting = try await Setting.query(on: database)
            .filter(\.$key == "poster_reminder_interval")
            .first() else {
                throw Abort(.internalServerError, reason: "Einstellung 'poster_reminder_interval' konnte nicht geladen werden.")
        }

        guard let posterToBeTakenDownSetting = try await Setting.query(on: database)
            .filter(\.$key == "poster_to_be_taken_down_interval")
            .first() else {
                throw Abort(.internalServerError, reason: "Einstellung 'poster_to_be_taken_down_interval' konnte nicht geladen werden.")
        }

        guard let posterDeletionIntervalSetting = try await Setting.query(on: database)
            .filter(\.$key == "poster_deletion_interval")
            .first() else {
                throw Abort(.internalServerError, reason: "Einstellung 'poster_deletion_interval' konnte nicht geladen werden.")
        }

        
        // Initiale Zuordnungen erstellen
        let serviceSettings = [
            ServiceSetting(serviceID: try authService.requireID(), settingID: try isRegistrationEnabled.requireID()),
            ServiceSetting(serviceID: try meetingService.requireID(), settingID: try defaultLanguage.requireID()),
            ServiceSetting(serviceID: try posterService.requireID(), settingID: try posterDeletionIntervalSetting.requireID()),
            ServiceSetting(serviceID: try posterService.requireID(), settingID: try posterToBeTakenDownSetting.requireID()),
            ServiceSetting(serviceID: try posterService.requireID(), settingID: try posterReminderSetting.requireID()),
            
        ]
        
        for serviceSetting in serviceSettings {
            try await serviceSetting.save(on: database)
        }
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("service_settings").delete()
    }
}

