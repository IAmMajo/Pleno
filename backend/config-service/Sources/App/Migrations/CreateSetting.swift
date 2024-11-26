//
//  settings.swift
//  config-service
//
//  Created by Dennis Sept on 02.11.24.
//

import Fluent
import Models

struct CreateSetting: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("settings")
            .id()
            .field("key", .string, .required)
            .field("datatype", .string, .required)
            .field("value", .string, .required)
            .field("description", .string)
            .create()
        
        // Initialdaten einfügen
        let settings = [
            Setting(
                            key: "registration_enabled" ,
                            datatype : Setting.DataType(rawValue: "Boolean")!,
                            value: "true",
                            description: "Die Einstellung aktiviert oder deaktiviert die neue Registrierung von Usern"
                    ),
            Setting(
                            key: "poster_deletion_interval",
                            datatype: Setting.DataType(rawValue: "Integer")!,
                            value: "30",
                            description: "Das Intervall in Tagen, nach dem Poster automatisch gelöscht werden, falls sie bereits abgehangen wurden"
                    )
            
            
        ]
        
        for setting in settings {
            try await setting.save(on: database)
        }
        
    }
    func revert(on database: Database) async throws {
        try await database.schema("settings").delete() 
    }
}
