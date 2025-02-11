import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import Models
import JWTKit

// configures your application
public func configure(_ app: Application) async throws {
    app.middleware.use(FileMiddleware(
        publicDirectory: app.directory.publicDirectory,
        defaultFile: "index.html"
    ))
    
    //JWT-Public-Key
    let publicCertPath = Environment.get("PUBLIC_CERT_PATH") ?? "/app/certs/jwt/public.pem"
    guard let publicKeyData = try? Data(contentsOf: URL(fileURLWithPath: publicCertPath)) else {
        throw Abort(.internalServerError, reason: "Error: Public key could not be loaded.")
    }
    guard let publicKey = try? ECDSAKey.public(pem: publicKeyData) else {
        throw Abort(.internalServerError, reason: "Error: The public key could not be decrypted properly.")
    }
    app.jwt.signers.use(.es256(key: publicKey), kid: "public")
    
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor",
        password: Environment.get("DATABASE_PASSWORD") ?? "example",
        database: Environment.get("DATABASE_NAME") ?? "kivop",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
    
    // migrations
    app.migrations.add(CreateService())
    app.migrations.add(CreateSetting())
    app.migrations.add(CreateServiceSetting())
    try await app.autoMigrate()
    
    try routes(app)
    
}

