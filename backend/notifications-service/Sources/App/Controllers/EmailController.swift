import NotificationsServiceDTOs
import Smtp
import Vapor
import VaporToOpenAPI

struct EmailController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let email = routes.grouped("internal", "email")
        email.post(use: send).openAPI(
            summary: "E-Mail senden",
            description: "Sendet eine E-Mail an einen Empfänger",
            body: .type(SendEmailDTO.self),
            contentType: .application(.json)
        )
    }
    
    @Sendable
    func send(req: Request) async throws -> HTTPStatus {
        let dto = try req.content.decode(SendEmailDTO.self)
        try await req.email.sendEmail(
            receiver: dto.receiver,
            subject: dto.subject,
            message: dto.message
        )
        return .ok
    }
}
