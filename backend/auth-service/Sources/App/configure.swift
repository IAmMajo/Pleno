import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import JWT
import JWTKit

private struct BaseURLKey: StorageKey {
    typealias Value = String
}

extension Application {
    var baseURL: String {
        self.storage[BaseURLKey.self] ?? "http://localhost:80"
    }
}


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
    
    
    let baseURL: String
    
    if let envDomain = Environment.get("DOMAIN"), !envDomain.isEmpty {
        baseURL = "https://\(envDomain)"
    } else {
        baseURL = "http://localhost:80"
    }
    
    app.logger.info("🌍 Base URL: \(baseURL)")
    
    app.storage[BaseURLKey.self] = baseURL

    let privateCertPath = "/app/certs/auth/private.pem"
    let privateKeyData = try Data(contentsOf: URL(fileURLWithPath: privateCertPath))
    
    let privateKey = try ECDSAKey.private(pem: privateKeyData)
    

    
    let publicCertPath = Environment.get("PUBLIC_CERT_PATH") ?? "/app/certs/jwt/public.pem"
    let publicKeyData = try Data(contentsOf: URL(fileURLWithPath: publicCertPath))
    
    let publicKey = try ECDSAKey.public(pem: publicKeyData)
    
    app.jwt.signers.use(.es256(key: privateKey), kid: "private")
    app.jwt.signers.use(.es256(key: publicKey), kid: "public")
    
    
    
    
    
    
    // Settings beim Start laden
    Task {
        do {
            let configServiceURL = Environment.get("CONFIG_SERVICE_URL") ?? "http://kivop-config-service"
            let serviceIDString = Environment.get("SERVICE_ID") ?? "e1e5f3b8-3c1d-4f58-a9e0-2e65d5d0a7d9"
            guard let serviceID = UUID(uuidString: serviceIDString) else {
                app.logger.error("Ungültige Service-ID.")
                return
            }
            try await SettingsManager.shared.loadSettings(from: configServiceURL, serviceID: serviceID, client: app.client, logger: app.logger)
        } catch {
            app.logger.error("Fehler beim Laden der Einstellungen: \(error.localizedDescription)")
        }
    }

    // migrations
    app.migrations.add(CreateIdentity())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateIdentityHistory())
    app.migrations.add(CreateEmailVerification())
    app.migrations.add(CreatePasswordResetToken())
    try await app.autoMigrate()
    
    //app.logger.logLevel = .debug
    
    // register routes
    try routes(app)
}
