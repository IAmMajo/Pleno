import NotificationsServiceDTOs
import Smtp
import Vapor
import VaporToOpenAPI

struct EmailController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let email = routes.grouped("internal", "email").groupedOpenAPI(
            tags: .init(name: "Intern", description: "Nur intern erreichbar.")
        )
        email.put(use: send).openAPI(
            summary: "E-Mail senden",
            description: "Sendet eine E-Mail an einen Empfänger",
            body: .type(SendEmailDTO.self),
            contentType: .application(.json)
        )
    }
    
    @Sendable
    func send(req: Request) async throws -> HTTPStatus {
        guard let dto = try? req.content.decode(SendEmailDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected SendEmailDTO.")
        }
        try await req.email.sendEmail(
            receiver: dto.receiver,
            subject: dto.subject,
            message: dto.message,
            template: dto.template,
            templateData: dto.templateData
        )
        return .noContent
    }
}
