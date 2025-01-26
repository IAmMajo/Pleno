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
        
        // Initialdaten einfügen
        let settings = [
            Setting(
                            key: "poster_deletion_interval",
                            datatype: .integer,
                            value: "30",
                            description: "Das Intervall in Tagen, nach dem Poster automatisch gelöscht werden, falls sie bereits abgehangen wurden"
                    ),
            Setting(
                            key: "poster_reminder_interval",
                            datatype: Setting.DataType(rawValue: "Integer")!,
                            value: "1",
                            description: "Das Intervall in Tagen vor Ablauf der Variabel expired_at. Anschließend wird dem Verantwortlichen eine Erinnerung geschickt, um die Poster ab zu hängen, bis diese abgehangen worden sind"
                    ),
            Setting(
                            key: "poster_to_be_taken_down_interval",
                            datatype: Setting.DataType(rawValue: "Integer")!,
                            value: "14",
                            description: "Das Intervall in Tagen, nachdem die zu abhängenden Poster angezeigt werden"
                    ),
            Setting(
                            key: "isRegistrationEnabled",
                            datatype: .boolean,
                            value: "false",
                            description: "Enables or disables user registrations"
                    ),
            Setting(
                            key: "defaultLanguage",
                            datatype: .languageCode,
                            value: "de",
                            description: "The language code used to define the default language of the application. For example: 'de' for German, 'en' for English"
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
