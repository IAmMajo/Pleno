import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor",
        password: Environment.get("DATABASE_PASSWORD") ?? "example",
        database: Environment.get("DATABASE_NAME") ?? "meeting_db",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

//    app.migrations.add(CreateTodo())
    app.migrations.add(CreateMeeting())
    app.migrations.add(CreateAttendance())
    app.migrations.add(CreateRecord())
    app.migrations.add(CreateVoting())
    app.migrations.add(CreateVotingOption())
    app.migrations.add(CreateVote())
    // register routes
    try routes(app)
}
