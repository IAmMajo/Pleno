import Fluent
import JWTKit
import Vapor
import VaporToOpenAPI

func routes(_ app: Application) throws {
    let jwtSigner = JWTSigner.hs256(key: "Ganzgeheimespasswort")
    let authMiddleware = AuthMiddleware(jwtSigner: jwtSigner, payloadType: JWTPayloadDTO.self)
    
    let authProtected = app.grouped(authMiddleware)
    let posters = authProtected.grouped("posters")
    
    try posters.register(collection: PosterController())
    try posters.register(collection: PosterPositionController())
    try app.register(collection: WebhookController())
    
    app.get("openapi.json") { req in
        app.routes.openAPI(
            info: .init(
                title: "KIVoP Poster Service API",
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
        openAPIPath: "/poster-service/openapi.json"
    )
}
