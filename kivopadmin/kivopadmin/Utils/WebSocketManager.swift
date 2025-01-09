import Foundation

class WebSocketService: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    
    @Published var liveStatus: String?
    @Published var errorMessage: String?
    
    private var votingId: UUID?

    func connect(to votingId: UUID) {
        // Schließe bestehende Verbindung, falls aktiv
        disconnect()
        
        self.votingId = votingId
        self.liveStatus = nil
        self.errorMessage = nil

        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            self.errorMessage = "Unauthorized: Token not found"
            return
        }

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(token)"]
        self.urlSession = URLSession(configuration: configuration)

        guard let url = URL(string: "wss://kivop.ipv64.net/meetings/votings/\(votingId)/live-status") else {
            self.errorMessage = "Invalid URL"
            return
        }

        webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()
        listenForMessages()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
    }

    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = "WebSocket error: \(error.localizedDescription)"
                }
            case .success(let message):
                DispatchQueue.main.async {
                    self.handleMessage(message)
                }
                self.listenForMessages()
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        DispatchQueue.main.async {
            switch message {
            case .string(let text):
                if text.starts(with: "ERROR:") {
                    self.errorMessage = text
                } else {
                    self.liveStatus = text
                }
            case .data(_):
                // Falls binäre Daten gesendet werden, kannst du hier Dekodierung implementieren
                print("Received binary data")
            @unknown default:
                self.errorMessage = "Unknown message type received."
            }
        }
    }
}
