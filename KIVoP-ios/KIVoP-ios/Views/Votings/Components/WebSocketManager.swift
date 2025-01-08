//
//  WebSocketManager.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 06.01.25.
//

import Foundation
import MeetingServiceDTOs

class WebSocketService: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    
    @Published var liveStatus: String?
    @Published var votingResults: GetVotingResultsDTO?
    @Published var errorMessage: String?
    
//    private var token: String
//    
//    init(token: String) {
//        self.token = token
//        let configuration = URLSessionConfiguration.default
//        configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(token)"]
//        self.urlSession = URLSession(configuration: configuration)
//    }
    
    func connect(to votingId: UUID) {
       // Reset state
           self.liveStatus = nil
           self.votingResults = nil
           self.errorMessage = nil
       
       if let token = UserDefaults.standard.string(forKey: "jwtToken") {
          let configuration = URLSessionConfiguration.default
          configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(token)"]
          self.urlSession = URLSession(configuration: configuration)
       } else {
          self.errorMessage = "Unauthorized: Token not found"
           return
       }
       
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
    
//    private func listenForMessages() {
//        webSocketTask?.receive { [weak self] result in
//            guard let self = self else { return }
//            
//            switch result {
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    self.errorMessage = "WebSocket error: \(error.localizedDescription)"
//                }
//                
//            case .success(let message):
//                DispatchQueue.main.async {
//                    self.handleMessage(message)
//                }
//                
//                // Continue listening for messages
//                self.listenForMessages()
//            }
//        }
//    }
//    
//    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
//        switch message {
//        case .string(let text):
//            if text.starts(with: "ERROR:") {
//                self.errorMessage = text
//            } else {
//                self.liveStatus = text
//            }
//            
//        case .data(let data):
//            do {
//                let decoder = JSONDecoder()
//                let results = try decoder.decode(GetVotingResultsDTO.self, from: data)
//                self.votingResults = results
//                disconnect() // Disconnect after receiving results
//            } catch {
//                self.errorMessage = "Failed to decode voting results: \(error.localizedDescription)"
//            }
//            
//        @unknown default:
//            self.errorMessage = "Unknown message type received"
//        }
//    }
   private func listenForMessages() {
       webSocketTask?.receive { [weak self] result in
           guard let self = self else { return }
           
           switch result {
           case .failure:
               // Ignore client-side WebSocket errors; server errors come as messages.
               self.listenForMessages() // Continue listening for server messages
               
           case .success(let message):
               DispatchQueue.main.async {
                   self.handleMessage(message)
               }
               
               // Continue listening for messages
               self.listenForMessages()
           }
       }
   }

   private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
       switch message {
       case .string(let text):
           if text.starts(with: "ERROR:") {
               // Process server errors only
               self.errorMessage = text
           } else {
               // Optionally handle other server messages
               self.liveStatus = text
           }
           
       case .data:
           // Ignore non-string messages, as server errors are expected as strings
           break
           
       @unknown default:
           self.errorMessage = "Unknown message type received"
       }
   }
}
