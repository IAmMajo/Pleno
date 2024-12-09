import Smtp
import Vapor
import VaporToOpenAPI

struct EmailController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let email = routes.grouped("email")
        email.post(use: send).openAPI(
            summary: "Send an email",
            description: "Send an email to a recipient",
            body: .type(SendEmailDTO.self),
            contentType: .application(.json)
        )
    }
    
    func send(req: Request) async throws -> HTTPStatus {
        let dto = try req.content.decode(SendEmailDTO.self)
        let email = Environment.get("SMTP_EMAIL") ?? ""
        if req.application.smtp.configuration.hostname.isEmpty || email.isEmpty {
            throw Abort(.internalServerError, reason: "SMTP configuration is missing")
        }
        var templateData = dto.templateData ?? [:]
        templateData["message"] = dto.message
        try await req.smtp.send(try Email(
            from: EmailAddress(address: email, name: Environment.get("APP_NAME")),
            to: [EmailAddress(address: dto.receiver)],
            subject: dto.subject,
            body: String(buffer: try await req.view.render(dto.template ?? "default", templateData).data),
            isBodyHtml: true
        ))
        return .ok
    }
}
