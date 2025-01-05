import AsyncHTTPClient
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
    }
    
    func extendRecord(req: Request) async throws -> Response {
        let dto = try req.content.decode(AISendMessageDTO.self)
        let aiURL = Environment.get("AI_URL") ?? ""
        let apiKey = Environment.get("AI_API_KEY") ?? ""
        let aiModel = Environment.get("AI_MODEL") ?? ""
        if aiURL.isEmpty || apiKey.isEmpty || aiModel.isEmpty {
            throw Abort(.internalServerError, reason: "AI configuration is missing")
        }
        let prompt = try await req.fileio.collectFile(
            at: "\(req.application.directory.resourcesDirectory)Prompts/extend-record.md"
        )
        var request = HTTPClientRequest(url: "\(aiURL)chat/completions")
        request.method = .POST
        request.headers.add(name: "Authorization", value: "Bearer \(apiKey)")
        request.headers.add(name: "Content-Type", value: "application/json")
        let json: [String: Any] = [
            "model": aiModel,
            "messages": [
                [
                    "role": "system",
                    "content": [
                        [
                            "type": "text",
                            "text": String(buffer: prompt)
                        ]
                    ]
                ],
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "Protokoll:\n\n\(dto.content)"
                        ]
                    ]
                ]
            ],
            "stream": true,
            "max_completion_tokens": 10000,
        ]
        request.body = .bytes(try JSONSerialization.data(withJSONObject: json))
        let response = try await req.application.http.client.shared.execute(request, timeout: .minutes(1))
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/markdown")
        return Response(
            headers: headers,
            body: .init(managedAsyncStream: { [response] writer in
                do {
                    for try await buffer in response.body {
                        var chunks = String(buffer: buffer).components(separatedBy: "data: ")
                        chunks.removeFirst()
                        for chunk in chunks {
                            let chunkJSON = try JSONSerialization.jsonObject(with: ByteBuffer(string: chunk)) as! [String: Any]
                            let choice = (chunkJSON["choices"] as! [[String: Any]])[0]
                            if choice["finish_reason"] as? String != nil {
                                try await writer.write(.end)
                                return
                            }
                            let content = (choice["delta"] as! [String: Any])["content"] as! String
                            try await writer.writeBuffer(ByteBuffer(string: content))
                        }
                    }
                } catch {
                    try? await writer.write(.error(error))
                }
            })
        )
    }
}
