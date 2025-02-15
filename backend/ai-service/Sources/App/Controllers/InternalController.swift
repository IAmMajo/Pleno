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

import Vapor
import Fluent
import AIServiceDTOs
import SwiftOpenAPI
import VaporToOpenAPI

struct InternalController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let openAPITag = TagObject(name: "Intern", description: "Nur intern erreichbar.")
        
        routes.get("healthcheck", use: healthcheck)
            .openAPI(
                tags: openAPITag,
                summary: "Healthcheck des Microservices",
                statusCode: .ok
            )
        
        routes.put("translate-record", ":lang", ":lang2", use: translateRecord).openAPI(
            tags: openAPITag,
            summary: "Protokoll übersetzen",
            description: "Übersetzt ein Sitzungsprotokoll in eine andere Sprache.",
            body: .type(AISendMessageDTO.self),
            contentType: .application(.json),
            response: .type(AISendMessageDTO.self),
            responseContentType: .application(.json),
            responseDescription: "Übersetztes Protokoll"
        )
    }
    
    /// **GET** `/internal/healthcheck`
    @Sendable func healthcheck(req: Request) -> HTTPResponseStatus {
        .ok
    }
    
    /// **POST** `/internal/translate-record/{lang}/{lang2}`
    @Sendable
    func translateRecord(req: Request) async throws -> AISendMessageDTO {
        guard let lang = req.parameters.get("lang") else {
            throw Abort(.badRequest, reason: "Missing request parameter! Expected lang.")
        }
        guard let lang2 = req.parameters.get("lang2") else {
            throw Abort(.badRequest, reason: "Missing request parameter! Expected lang2.")
        }
        guard let dto = try? req.content.decode(AISendMessageDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected AISendMessageDTO.")
        }
        let aiResponse = try await req.ai.getAIResponse(
            promptName: "translate-record",
            message: "\(lang) to \(lang2):\n\n\(dto.content)",
            maxCompletionTokens: 10000
        )
        return .init(content: aiResponse)
    }
}
