// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import NIOSSL
import FCM
import Fluent
import FluentPostgresDriver
import JWT
import Leaf
import Smtp
import Vapor
import VaporAPNS
import JWTKit

// configures your application
public func configure(_ app: Application) async throws {
    app.middleware.use(FileMiddleware(
        publicDirectory: app.directory.publicDirectory,
        defaultFile: "index.html"
    ))

    app.views.use(.leaf)

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
            let serviceIDString = Environment.get("SERVICE_ID") ?? "a4c1f7b9-9aaf-4b8e-9c56-4e2a8c0c3f7d"
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
    app.migrations.add(CreateNotificationDevice())
    try await app.autoMigrate()
    
    //JWT-Public-Key
    let publicCertPath = Environment.get("PUBLIC_CERT_PATH") ?? "/app/certs/jwt/public.pem"
    guard let publicKeyData = try? Data(contentsOf: URL(fileURLWithPath: publicCertPath)) else {
        throw Abort(.internalServerError, reason: "Error: Public key could not be loaded.")
    }
    guard let publicKey = try? ECDSAKey.public(pem: publicKeyData) else {
        throw Abort(.internalServerError, reason: "Error: The public key could not be decrypted properly.")
    }
    app.jwt.signers.use(.es256(key: publicKey), kid: "public")
    
    let apnsTeamID = Environment.get("APNS_TEAM_ID") ?? ""
    let apnsKeyID = Environment.get("APNS_KEY_ID") ?? ""
    let apnsPrivateKey = Environment.get("APNS_PRIVATE_KEY") ?? ""
    if !apnsTeamID.isEmpty && !apnsKeyID.isEmpty && !apnsPrivateKey.isEmpty {
        app.apns.containers.use(
            .init(
                authenticationMethod: .jwt(
                    privateKey: try .loadFrom(string: apnsPrivateKey),
                    keyIdentifier: apnsKeyID,
                    teamIdentifier: apnsTeamID
                ),
                environment: .production
            ),
            eventLoopGroupProvider: .shared(app.eventLoopGroup),
            responseDecoder: JSONDecoder(),
            requestEncoder: JSONEncoder(),
            as: .default
        )
    }
    
    let fcmEmail = Environment.get("FCM_EMAIL") ?? ""
    let fcmProjectID = Environment.get("FCM_PROJECT_ID") ?? ""
    let fcmPrivateKey = Environment.get("FCM_PRIVATE_KEY") ?? ""
    if !fcmEmail.isEmpty && !fcmProjectID.isEmpty && !fcmPrivateKey.isEmpty {
        app.fcm.configuration = .envServiceAccountKeyFields
    }

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
