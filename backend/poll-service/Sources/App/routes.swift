import Fluent
import JWTKit
import Vapor
import VaporToOpenAPI
import Models

func routes(_ app: Application) throws {
    // Einbinden der Middleware und des JWTSigner
    let authMiddleware = AuthMiddleware(payloadType: JWTPayloadDTO.self)
    
    let authProtected = app.grouped(authMiddleware)
    let polls = authProtected.grouped("polls")
    try polls.register(collection: PollController())
    
    try app.register(collection: WebhookController())
    try app.grouped("internal").register(collection: InternalController())
    
    app.get("openapi.json") { req in
        app.routes.openAPI(
            info: .init(
                title: OpenAPIInfo.title,
                summary: OpenAPIInfo.summary,
                description: OpenAPIInfo.description,
                termsOfService: OpenAPIInfo.termsOfService,
                contact: OpenAPIInfo.contact == nil ? nil :
                        .init(name: OpenAPIInfo.contact!.name,
                              url: OpenAPIInfo.contact!.url,
                              email: OpenAPIInfo.contact!.email),
                license: OpenAPIInfo.license == nil ? nil :
                        .init(
                            name: OpenAPIInfo.license!.name,
                            identifier: OpenAPIInfo.license!.identifier,
                            url: OpenAPIInfo.license!.url
                        ),
                version: "\(OpenAPIInfo.version.major).\(OpenAPIInfo.version.minor).\(OpenAPIInfo.version.patch)"
            )
        )
    }
    .excludeFromOpenAPI()
    
    app.stoplightDocumentation(
        "stoplight",
        openAPIPath: "/poll-service/openapi.json"
    )
}
