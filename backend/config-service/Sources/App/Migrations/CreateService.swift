import Fluent
import Models

struct CreateService: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("services")
            .id()
            .field("name", .string, .required)
            .field("webhook_url", .string)
            .field("description", .string)
            .field("active", .bool, .required)
            .create()
        
        // Initialdaten für die Services einfügen
        let services = [
            Service(
                name: "Auth-Service",
                webhook_url: "http://auth/webhook",
                description: "Handles authentication and authorization tasks.",
                active: true
            ),
            Service(
                name: "Meeting-Service",
                webhook_url: "http://meeting/webhook",
                description: "Manages meetings",
                active: true
            ),
            Service(
                name: "Notification-Service",
                webhook_url: "http://notification/webhook",
                description: "Sends notifications and alerts.",
                active: true
            ),
            Service(
                name: "Poster-Service",
                webhook_url: "http://poster/webhook",
                description: "Manages Poster positions",
                active: true
            )
        ]

        for service in services {
            try await service.save(on: database)
        }
    }

    func revert(on database: Database) async throws {
        try await database.schema("services").delete()
    }
}
