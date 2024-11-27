import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Smtp
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.views.use(.leaf)

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor",
        password: Environment.get("DATABASE_PASSWORD") ?? "example",
        database: Environment.get("DATABASE_NAME") ?? "kivop",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    var smtpSignInMethod = SignInMethod.anonymous
    let smtpUsername = Environment.get("SMTP_USERNAME") ?? ""
    if !smtpUsername.isEmpty {
        smtpSignInMethod = .credentials(
            username: smtpUsername,
            password: Environment.get("SMTP_PASSWORD") ?? ""
        )
    }
    let smtpSecure: SmtpSecureChannel =
        switch Environment.get("SMTP_SECURE") {
        case "SSL":
            .ssl
        case "STARTTLS":
            .startTls
        case "STARTTLS_WHEN_AVAILABLE":
            .startTlsWhenAvailable
        default:
            .none
        }
    app.smtp.configuration = .init(
        hostname: Environment.get("SMTP_HOST") ?? "",
        port: Environment.get("SMTP_PORT").flatMap(Int.init(_:)) ?? 465,
        signInMethod: smtpSignInMethod,
        secure: smtpSecure
    )

    // register routes
    try routes(app)
}
