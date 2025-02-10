import Vapor
@preconcurrency import JWT
@preconcurrency import VaporToOpenAPI

struct AuthMiddleware: AsyncMiddleware {
    let payloadType: JWTPayloadDTO.Type
    
    init(payloadType: JWTPayloadDTO.Type) {
        self.payloadType = payloadType
    }
    
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let  token = request.headers.bearerAuthorization?.token ?? request.cookies["token"]?.string else {
            request.logger.warning("Not Token found in Authorization header or cookies.")
            throw Abort(.unauthorized, reason: "Authorization token required")
        }
        
        do {
            let payload = try request.jwt.verify(token, as: JWTPayloadDTO.self)
            
            request.jwtPayload = payload
            
        } catch {
            request.logger.error("Token verification failed: \(error)")
            throw Abort(.unauthorized, reason: "Invalid or expired token" )
        }
        return try await next.respond(to: request)
    }
}

extension Request {
    private struct JWTKey: StorageKey {
        typealias Value = JWTPayloadDTO
    }
    var jwtPayload: JWTPayloadDTO? {
        get { storage[JWTKey.self] }
        set { storage[JWTKey.self] = newValue }
    }
}

extension AuthMiddleware {
    static let schemeObject = AuthSchemeObject.bearer()
}
