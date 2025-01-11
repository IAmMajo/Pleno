import Vapor
@preconcurrency import JWT
@preconcurrency import VaporToOpenAPI

struct AdminMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // JWT-Payload abfragen
        let payload = request.jwtPayload

        // Prüfen auf Admin
        guard payload.isAdmin == true else {
            throw Abort(.forbidden, reason: "User is not an admin.")
        }
        
        return try await next.respond(to: request)
    }
}

extension AdminMiddleware {
    static let schemeObject = AuthSchemeObject.bearer(description: "Admin Token")
}
