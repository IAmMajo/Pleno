import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import JWTKit

// configures your application
public func configure(_ app: Application) async throws {
    app.middleware.use(FileMiddleware(
        publicDirectory: app.directory.publicDirectory,
        defaultFile: "index.html"
    ))

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
            let serviceIDString = Environment.get("SERVICE_ID") ?? "d355c12b-19c6-4f67-b5b5-837030ed09e6"
            guard let serviceID = UUID(uuidString: serviceIDString) else {
                app.logger.error("Ungültige Service-ID.")
                return
            }
            try await SettingsManager.shared.loadSettings(from: configServiceURL, serviceID: serviceID, client: app.client, logger: app.logger)
        } catch {
            app.logger.error("Fehler beim Laden der Einstellungen: \(error.localizedDescription)")
        }
    }
    
    app.migrations.add(CreatePlenoEvent())
    app.migrations.add(CreateEventParticipant())
    app.migrations.add(CreateEventRideInterestedParty())
    app.migrations.add(CreateEventRide())
    app.migrations.add(CreateEventRideRequest())

    app.migrations.add(CreateSpecialRide())
    app.migrations.add(CreateSpecialRideRequest())
    
    try await app.autoMigrate()
    
    let publicCertPath = Environment.get("PUBLIC_CERT_PATH") ?? "/app/certs/jwt/public.pem"
    guard let publicKeyData = try? Data(contentsOf: URL(fileURLWithPath: publicCertPath)) else {
        throw Abort(.internalServerError, reason: "Error: Public key could not be loaded.")
    }
    guard let publicKey = try? ECDSAKey.public(pem: publicKeyData) else {
        throw Abort(.internalServerError, reason: "Error: The public key could not be decrypted properly.")
    }
    app.jwt.signers.use(.es256(key: publicKey), kid: "public")
    
    // register routes
    try routes(app)
}
