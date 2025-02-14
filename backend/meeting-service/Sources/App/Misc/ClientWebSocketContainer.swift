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

import Foundation
import Vapor

final class ClientWebSocketContainer: @unchecked Sendable {
    var eventLoop: EventLoop
    var clientWebsockets: [UUID: WebSocket]
    
    var isEmpty: Bool {
        clientWebsockets.isEmpty
    }
    
    init(eventLoop: EventLoop, clientWebsockets: [UUID: WebSocket] = [:]) {
        self.eventLoop = eventLoop
        self.clientWebsockets = clientWebsockets
    }
    
    func add(_ clientId: UUID,_ webSocket: WebSocket) {
        self.clientWebsockets[clientId] = webSocket
        webSocket.onClose.whenComplete { _ in
            self.remove(clientId)
        }
    }
    
    func remove(_ clientId: UUID) {
        self.clientWebsockets.removeValue(forKey: clientId)
    }
    
    func getWebSocket(_ byClientId: UUID) -> WebSocket? {
        return self.clientWebsockets[byClientId]
    }
    
    func sendText(_ text: String) async throws {
        for ws in clientWebsockets.values {
            try await ws.send(text)
        }
    }
    
    func sendBinary(_ binary: [UInt8]) async throws {
        for ws in clientWebsockets.values {
            try await ws.send(binary)
        }
    }
    
    func sendBinary(_ binary: Data) async throws {
        try await sendBinary(binary.base64Bytes())
    }
    
    func closeAllConnections() async throws {
        for cw in clientWebsockets {
            try await cw.value.close()
            clientWebsockets.removeValue(forKey: cw.key)
        }
    }
    
    deinit {
        try! self.eventLoop.flatten(
            self.clientWebsockets.values.map({ $0.close() })
        ).wait()
    }
}
