import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import Models
// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor",
        password: Environment.get("DATABASE_PASSWORD") ?? "example",
        database: Environment.get("DATABASE_NAME") ?? "config_db",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
    // Migrationen
    
    app.migrations.add(CreateService())
    app.migrations.add(CreateSetting())
    app.migrations.add(CreateServiceSetting())
    // Migrationen ausführen
    try await app.autoMigrate()
    
    try routes(app)
   
}

