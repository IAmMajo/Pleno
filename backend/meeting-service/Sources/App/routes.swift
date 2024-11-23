import Fluent
import JWTKit
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    // Einbinden der Middleware und des JWTSigner
    let jwtSigner = JWTSigner.hs256(key: "Ganzgeheimespasswort")
    let authMiddleware = AuthMiddleware(jwtSigner: jwtSigner, payloadType: JWTPayloadDTO.self)
    
    let authProtected = app.grouped(authMiddleware)
    let meetings = authProtected.grouped("meetings")
    try meetings.register(collection: MeetingController())
    try meetings.register(collection: AttendanceController())
    try meetings.register(collection: VotingController())
    try meetings.register(collection: RecordController())
    
    app.get("**", "brew", "coffee") { req -> HTTPStatus in // 418
        .imATeapot
    }
}
