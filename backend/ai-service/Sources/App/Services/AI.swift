import AsyncHTTPClient
import Vapor

struct AI {
    let application: Application
    let fileio: FileIO

    func getAIResponse(promptName: String, message: String, maxCompletionTokens: Int) async throws -> Response {
        let aiURL = Environment.get("AI_URL") ?? ""
        let apiKey = Environment.get("AI_API_KEY") ?? ""
        let aiModel = Environment.get("AI_MODEL") ?? ""
        if aiURL.isEmpty || apiKey.isEmpty || aiModel.isEmpty {
            throw Abort(.internalServerError, reason: "AI configuration is missing")
        }
        let prompt = try await fileio.collectFile(
            at: "\(application.directory.resourcesDirectory)Prompts/\(promptName).md"
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
                            "text": message
                        ]
                    ]
                ]
            ],
            "stream": true,
            "max_completion_tokens": maxCompletionTokens,
        ]
        request.body = .bytes(try JSONSerialization.data(withJSONObject: json))
        let response = try await application.http.client.shared.execute(request, timeout: .minutes(1))
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

extension Request {
    var ai: AI {
        .init(application: self.application, fileio: self.fileio)
    }
}
