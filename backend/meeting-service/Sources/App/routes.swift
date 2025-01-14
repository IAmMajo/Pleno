import Fluent
import JWTKit
import Vapor
import VaporToOpenAPI
import Models

func routes(_ app: Application) throws {
    // Einbinden der Middleware und des JWTSigner
    let jwtSigner = JWTSigner.hs256(key: "Ganzgeheimespasswort")
    let authMiddleware = AuthMiddleware(jwtSigner: jwtSigner, payloadType: JWTPayloadDTO.self)
    
    let authProtected = app.grouped(authMiddleware)
    let meetings = authProtected.grouped("meetings")
    try meetings.register(collection: MeetingController())
    try meetings.register(collection: AttendanceController())
    try meetings.register(collection: VotingController(eventLoop: app.eventLoopGroup.next()))
    try meetings.register(collection: RecordController())
    try app.register(collection: WebhookController())
    try app.grouped("internal").register(collection: InternalController())
    
    app.get("brew", "coffee") { req -> HTTPStatus in // 418
            .imATeapot
    }
    .excludeFromOpenAPI()
    
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
        openAPIPath: "/meeting-service/openapi.json"
    )
}
