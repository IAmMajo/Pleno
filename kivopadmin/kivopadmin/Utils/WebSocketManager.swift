//
//  WebSocketManager.swift
//  kivopadmin
//
//  Created by Amine Ahamri on 07.01.25.
//


//
//  WebSocketManager.swift
//  kivopadmin
//
//  Created by Amine Ahamri on 02.01.25.
//


import Foundation
import Combine
import MeetingServiceDTOs

class WebSocketManager: ObservableObject {
    @Published var liveResults: GetVotingResultsDTO?

    private var webSocketTask: URLSessionWebSocketTask?
    private var cancellables = Set<AnyCancellable>()

    init(url: URL) {
        connect(to: url)
    }

    deinit {
        disconnect()
    }

    func connect(to url: URL) {
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        listenForMessages()
        webSocketTask?.resume()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }

    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    self?.handleData(data)
                case .string(let string):
                    self?.handleString(string)
                @unknown default:
                    break
                }
            case .failure(let error):
                print("WebSocket error: \(error.localizedDescription)")
            }

            // Weiter zuhören
            self?.listenForMessages()
        }
    }

    private func handleData(_ data: Data) {
        do {
            let decodedResults = try JSONDecoder().decode(GetVotingResultsDTO.self, from: data)
            DispatchQueue.main.async {
                self.liveResults = decodedResults
            }
        } catch {
            print("Fehler beim Decodieren der Daten: \(error)")
        }
    }

    private func handleString(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        handleData(data)
    }
}
