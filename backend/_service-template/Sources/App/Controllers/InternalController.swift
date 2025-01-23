import Vapor
import Fluent
import SwiftOpenAPI
import VaporToOpenAPI

struct InternalController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let openAPITag = TagObject(name: "Intern", description: "Nur intern erreichbar.")
        
        routes.get("healthcheck", use: healthcheck)
            .openAPI(tags: openAPITag, summary: "Healthcheck des Microservices", statusCode: .ok)
    }
    
    /// **GET** `/internal/healthcheck`
    @Sendable func healthcheck(req: Request) -> HTTPResponseStatus {
        .ok
    }
}
