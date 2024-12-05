import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    app.middleware.use(FileMiddleware(
        publicDirectory: app.directory.publicDirectory,
        defaultFile: "index.html"
    ))
    
    app.jwt.signers.use(.hs256(key: "Ganzgeheimespasswort"))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor",
        password: Environment.get("DATABASE_PASSWORD") ?? "example",
        database: Environment.get("DATABASE_NAME") ?? "kivop",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

//    app.migrations.add(CreateTodo())
    app.migrations.add(CreatePlace())
    app.migrations.add(CreateLocation())
    app.migrations.add(CreateMeeting())
    app.migrations.add(CreateAttendance())
    app.migrations.add(CreateRecord())
    app.migrations.add(CreateVoting())
    app.migrations.add(CreateVotingOption())
    app.migrations.add(CreateVote())
    // register routes
    try routes(app)
}
