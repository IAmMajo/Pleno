import AsyncHTTPClient
import Vapor

struct AI {
    let application: Application
    let client: Client
    let fileio: FileIO
    
    func getAIResponse(promptName: String, message: String, maxCompletionTokens: Int) async throws -> String {
        let aiURL = Environment.get("AI_URL") ?? ""
        let apiKey = Environment.get("AI_API_KEY") ?? ""
        let aiModel = Environment.get("AI_MODEL") ?? ""
        guard !aiURL.isEmpty, !apiKey.isEmpty, !aiModel.isEmpty else {
            throw Abort(.internalServerError, reason: "AI configuration is missing")
        }
        let prompt = try await fileio.collectFile(
            at: "\(application.directory.resourcesDirectory)Prompts/\(promptName).md"
        )
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
            "max_completion_tokens": maxCompletionTokens,
        ]
        let response = try await client.post("\(aiURL)chat/completions") { req in
            req.headers.add(name: "Authorization", value: "Bearer \(apiKey)")
            req.headers.add(name: "Content-Type", value: "application/json")
            req.body = .init(data: try JSONSerialization.data(withJSONObject: json))
        }
        guard
            let body = response.body,
            let bodyJSON = try JSONSerialization.jsonObject(with: body) as? [String: Any],
            let choices = bodyJSON["choices"] as? [[String: Any]],
            let message = choices[0]["message"] as? [String: Any],
            let content = message["content"] as? String
        else {
            throw Abort(.internalServerError, reason: "Invalid OpenAI response body")
        }
        return content
    }

    func getStreamedAIResponse(promptName: String, message: String, maxCompletionTokens: Int) async throws -> Response {
        let aiURL = Environment.get("AI_URL") ?? ""
        let apiKey = Environment.get("AI_API_KEY") ?? ""
        let aiModel = Environment.get("AI_MODEL") ?? ""
        guard !aiURL.isEmpty, !apiKey.isEmpty, !aiModel.isEmpty else {
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
                            guard
                                let chunkJSON = try JSONSerialization.jsonObject(with: ByteBuffer(string: chunk)) as? [String: Any],
                                let choices = chunkJSON["choices"] as? [[String: Any]]
                            else {
                                throw Abort(.internalServerError, reason: "Invalid OpenAI response body")
                            }
                            let choice = choices[0]
                            guard choice["finish_reason"] as? String == nil else {
                                try await writer.write(.end)
                                return
                            }
                            guard
                                let delta = choice["delta"] as? [String: Any],
                                let content = delta["content"] as? String
                            else {
                                throw Abort(.internalServerError, reason: "Invalid OpenAI response body")
                            }
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
        .init(
            application: self.application,
            client: self.client,
            fileio: self.fileio
        )
    }
}
