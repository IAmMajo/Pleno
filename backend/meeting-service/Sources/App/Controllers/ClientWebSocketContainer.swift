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
