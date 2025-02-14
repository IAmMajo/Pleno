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

