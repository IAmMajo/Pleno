import Fluent
import JWTKit
import Vapor
import VaporToOpenAPI

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
          title: "KIVoP Meeting Service API",
          license: .init(
            name: "MIT-0",
            url: URL(string: "https://github.com/aws/mit-0")
          ),
          version: "0.1.0"
        )
      )
    }
    .excludeFromOpenAPI()

    app.stoplightDocumentation(
        "stoplight",
        openAPIPath: "/meeting-service/openapi.json"
    )
}
