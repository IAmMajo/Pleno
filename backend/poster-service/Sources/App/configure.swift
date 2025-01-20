// configure.swift

import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor


// Konfiguriert deine Anwendung
public func configure(_ app: Application) async throws {
    app.middleware.use(FileMiddleware(
        publicDirectory: app.directory.publicDirectory,
        defaultFile: "index.html"
    ))

    // Datenbankkonfiguration
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor",
        password: Environment.get("DATABASE_PASSWORD") ?? "example",
        database: Environment.get("DATABASE_NAME") ?? "kivop",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
    
    // Settings beim Start laden
    Task {
        do {
            let configServiceURL = Environment.get("CONFIG_SERVICE_URL") ?? "http://kivop-config-service"
            let serviceIDString = Environment.get("SERVICE_ID") ?? "d3c1f7b9-8aaf-4b8e-9c56-4e2a8c0c3f7c"
            
            guard let serviceID = UUID(uuidString: serviceIDString) else {
                app.logger.error("Ungültige Service-ID.")
                return
            }
            
            try await SettingsManager.shared.loadSettings(
                from: configServiceURL,
                serviceID: serviceID,
                client: app.client,
                logger: app.logger
            )
            

        } catch {
            app.logger.error("Fehler beim Laden der Einstellungen: \(error.localizedDescription)")
        }
    }
    
    // Migrations registrieren
    app.migrations.add(CreatePosters())
    app.migrations.add(CreatePosterPositions())
    app.migrations.add(CreatePosterPositionResponsibilities())
    // Erinnerungen für aufgehangene Poster versenden
    app.lifecycle.use(DailyCheckTask())

    // Routen registrieren
    try routes(app)
}
