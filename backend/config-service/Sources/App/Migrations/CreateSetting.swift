import Fluent
import Models

struct CreateSetting: AsyncMigration {
    func prepare(on database: Database) async throws {
        
        let datatype = try await database.enum("datatype")
            .case("Integer")
            .case("String")
            .case("languageCode")
            .case("Float")
            .case ("Boolean")
            .case ("Date")
            .case ("DateTime")
            .case ("Time")
            .case ("Binary")
            .case ("Text")
            .case ("JSON")
            .create()
        
        try await database.schema("settings")
            .id()
            .field("key", .string, .required)
            .field("datatype", datatype, .required)
            .field("value", .string, .required)
            .field("description", .string)
            .create()
        
        // Insert initial data
        let settings = [
            Setting(
                key: "poster_deletion_interval",
                datatype: .integer,
                value: "30",
                description: "The interval in days after which posters are automatically deleted if they have already been taken down."
            ),
            Setting(
                key: "poster_reminder_interval",
                datatype: .integer,
                value: "1",
                description: "The interval in days before the 'expired_at' variable is reached. A reminder is then sent to the responsible person to take down the posters until they have been removed."
            ),
            Setting(
                key: "poster_to_be_taken_down_interval",
                datatype: .integer,
                value: "14",
                description: "The interval in days after which posters that need to be taken down are displayed."
            ),
            Setting(
                key: "isRegistrationEnabled",
                datatype: .boolean,
                value: "true",
                description: "Enables or disables user registrations."
            ),
            Setting(
                key: "defaultLanguage",
                datatype: .languageCode,
                value: "de",
                description: "The language code used to define the default language of the application. For example: 'de' for German, 'en' for English."
            ),
        ]
        
        for setting in settings {
            try await setting.save(on: database)
        }
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("settings").delete()
        try await database.enum("datatype").delete()
    }
}
