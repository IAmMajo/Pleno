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
        
        routes.post("translate-record", ":lang", ":lang2", use: translateRecord).openAPI(
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
        let lang = req.parameters.get("lang")!
        let lang2 = req.parameters.get("lang2")!
        let dto = try req.content.decode(AISendMessageDTO.self)
        let aiResponse = try await req.ai.getAIResponse(
            promptName: "translate-record",
            message: "\(lang) to \(lang2):\n\n\(dto.content)",
            maxCompletionTokens: 10000
        )
        return .init(content: aiResponse)
    }
}
