import Vapor
import VaporToOpenAPI

struct AIController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let ai = routes.grouped("ai")
        ai.post("extend-record", use: extendRecord).openAPI(
            summary: "Protokoll erweitern",
            description:
                "Konvertiert ein stichpunktartiges Sitzungsprotokoll in einen zusammenhängenden, gut formulierten " +
                "Text.\n\nDie Antwort wird als Text statt als JSON zurückgegeben, damit die Antwort gestreamt werden " +
                "kann. Alle von der AI generierten Wörter/Buchstaben werden direkt gesendet und es wird nicht " +
                "gewartet bis die komplette Antwort fertig generiert ist. In den Frontends sollte auch dafür gesorgt " +
                "werden, dass alle empfangenen Wörter/Buchstaben direkt angezeigt werden und nicht auf die komplette " +
                "Antwort gewartet wird.",
            body: .type(AISendMessageDTO.self),
            contentType: .application(.json),
            response: .type(String.self),
            responseContentType: .init(rawValue: "text/markdown"),
            responseDescription: "Erweitertes Protokoll"
        )
        ai.post("generate-social-media-post", use: generateSocialMediaPost).openAPI(
            summary: "Social Media Post generieren",
            description:
                "Konvertiert ein Sitzungsprotokoll in einen kurzen, ansprechenden Social-Media-Beitrag.\n\nDie " +
                "Antwort wird als Text statt als JSON zurückgegeben, damit die Antwort gestreamt werden kann. Alle " +
                "von der AI generierten Wörter/Buchstaben werden direkt gesendet und es wird nicht gewartet bis die " +
                "komplette Antwort fertig generiert ist. In den Frontends sollte auch dafür gesorgt werden, dass " +
                "alle empfangenen Wörter/Buchstaben direkt angezeigt werden und nicht auf die komplette Antwort " +
                "gewartet wird.",
            body: .type(AISendMessageDTO.self),
            contentType: .application(.json),
            response: .type(String.self),
            responseContentType: .init(rawValue: "text/markdown"),
            responseDescription: "Social Media Post"
        )
    }
    @Sendable
    func extendRecord(req: Request) async throws -> Response {
        let dto = try req.content.decode(AISendMessageDTO.self)
        return try await req.ai.getAIResponse(
            promptName: "extend-record",
            message: "Protokoll:\n\n\(dto.content)",
            maxCompletionTokens: 10000
        )
    }
    @Sendable
    func generateSocialMediaPost(req: Request) async throws -> Response {
        let dto = try req.content.decode(AISendMessageDTO.self)
        return try await req.ai.getAIResponse(
            promptName: "generate-social-media-post",
            message: "Protokoll:\n\n\(dto.content)",
            maxCompletionTokens: 1000
        )
    }
}
