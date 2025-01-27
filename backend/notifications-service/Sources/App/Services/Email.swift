import AsyncHTTPClient
import Smtp
import Vapor

struct Email {
    let application: Application
    let view: ViewRenderer
    let smtp: Request.Smtp
    
    func sendEmail(
        receiver: String,
        subject: String,
        message: String?,
        template: String? = nil,
        templateData: [String: String]? = nil
    ) async throws {
        let email = Environment.get("SMTP_EMAIL") ?? ""
        if application.smtp.configuration.hostname.isEmpty || email.isEmpty {
            throw Abort(.internalServerError, reason: "SMTP configuration is missing")
        }
        var templateData = templateData ?? [:]
        templateData["subject"] = subject
        templateData["message"] = message
        let body = try await view.render(template ?? "default", templateData).data
        try await smtp.send(try Smtp.Email(
            from: EmailAddress(address: email, name: Environment.get("APP_NAME")),
            to: [EmailAddress(address: receiver)],
            subject: subject,
            body: String(buffer: body),
            isBodyHtml: true
        ))
    }
}

extension Request {
    var email: Email {
        .init(
            application: self.application,
            view: self.view,
            smtp: self.smtp
        )
    }
}
