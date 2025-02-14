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
import Fluent
import FluentPostgresDriver
import Vapor

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
            let serviceIDString = Environment.get("SERVICE_ID") ?? "SRV_CONFIG_SERVICE_UUID_PLACEHOLDER"
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
    try await app.autoMigrate()

    // register routes
    try routes(app)
}
