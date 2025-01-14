import Fluent
import Models
import Vapor


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
                id: UUID(uuidString: "e1e5f3b8-3c1d-4f58-a9e0-2e65d5d0a7d9")!,
                name: "Auth-Service",
                webhook_url: "http://kivop-auth-service/webhook",
                description: "Handles authentication and authorization tasks.",
                active: true
            ),
            Service(
                id: UUID(uuidString: "b6e7d4c1-9aaf-4b8e-9c56-4e2a8c0c3f7b")!,
                name: "Meeting-Service",
                webhook_url: "http://kivop-meeting-service/webhook",
                description: "Manages meetings",
                active: true
            ),
            Service(
                id: UUID(uuidString: "a4c1f7b9-9aaf-4b8e-9c56-4e2a8c0c3f7d")!,
                name: "Notification-Service",
                webhook_url: "http://kivop-notifications-service/webhook",
                description: "Sends notifications and alerts.",
                active: true
            ),
            Service(
                id: UUID(uuidString: "d3c1f7b9-8aaf-4b8e-9c56-4e2a8c0c3f7c")!,
                name: "Poster-Service",
                webhook_url: "http://kivop-poster-service/webhook",
                description: "Manages Poster positions",
                active: true
            ),
            Service(
                id: UUID(uuidString: "d355c12b-19c6-4f67-b5b5-837030ed09e6")!,
                name: "Ride-Service",
                webhook_url: "http://kivop-ride-service/webhook",
                description: "Organisiert die Planung von Gemeinschaftsfahrten",
                active: true
            ),
            Service(
                id: UUID(uuidString: "47900b1a-63c2-45fb-a708-adf5e1ed8e11")!,
                name: "Ai-Service",
                webhook_url: "http://kivop-ai-service/webhook",
                description: "Mit dem Ai-Service lassen sich Protokolle ausformulieren und Social Media Posts erstellen",
                active: true
            ), // Initialdaten für die Services einfügen: END
        ]

        for service in services {
            try await service.save(on: database)
        }
    }

    func revert(on database: Database) async throws {
        try await database.schema("services").delete()
    }
}
