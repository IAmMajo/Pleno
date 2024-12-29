import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import JWT


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
    
    app.migrations.add(CreateIdentity())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateIdentityHistory())
    app.migrations.add(CreateEmailVerification())
    app.migrations.add(CreatePasswordResetToken())
    
    app.jwt.signers.use(.hs256(key: "Ganzgeheimespasswort"))
    
    app.logger.logLevel = .debug
    
    app.http.client.configuration.timeout = .init(
        connect: .seconds(10),
        read: .seconds(30)
    )


    // register routes
    try routes(app)
}
