import Vapor
@preconcurrency import JWT

struct AuthMiddleware: AsyncMiddleware {
    let jwtSigner: JWTSigner
    
    init(jwtSigner: JWTSigner) {
        self.jwtSigner = jwtSigner
    }
    
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let  token = request.headers.bearerAuthorization?.token ?? request.cookies["token"]?.string else {
            request.logger.warning("Not Token found in Authorization header or cookies.")
            throw Abort(.unauthorized, reason: "Authorization token required")
        }
        
        do {
            let _ = try jwtSigner.verify(token, as: JWTPayloadDTO.self)
            return try await next.respond(to: request)
        } catch {
            request.logger.error("Token verification failed: \(error)")
            throw Abort(.unauthorized, reason: "Invalid or expired token")
        }
    }
}

