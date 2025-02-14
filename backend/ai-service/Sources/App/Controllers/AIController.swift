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

import AIServiceDTOs
import Vapor
import VaporToOpenAPI

struct AIController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let openAPITag = TagObject(name: "AI")
        
        routes.put("extend-record", ":lang", use: extendRecord).openAPI(
            tags: openAPITag,
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
        routes.put("generate-social-media-post", ":lang", use: generateSocialMediaPost).openAPI(
            tags: openAPITag,
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
        guard let lang = req.parameters.get("lang") else {
            throw Abort(.badRequest, reason: "Missing request parameter! Expected lang.")
        }
        guard let dto = try? req.content.decode(AISendMessageDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected AISendMessageDTO.")
        }
        return try await req.ai.getStreamedAIResponse(
            promptName: "extend-record",
            message: "Sprachcode \"\(lang)\":\n\n\(dto.content)",
            maxCompletionTokens: 10000
        )
    }

    @Sendable
    func generateSocialMediaPost(req: Request) async throws -> Response {
        guard let lang = req.parameters.get("lang") else {
            throw Abort(.badRequest, reason: "Missing request parameter! Expected lang.")
        }
        guard let dto = try? req.content.decode(AISendMessageDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected AISendMessageDTO.")
        }
        return try await req.ai.getStreamedAIResponse(
            promptName: "generate-social-media-post",
            message: "Sprachcode \"\(lang)\":\n\n\(dto.content)",
            maxCompletionTokens: 1000
        )
    }
}
