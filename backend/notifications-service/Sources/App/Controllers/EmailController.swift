// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
