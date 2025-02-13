// This file is licensed under the MIT-0 License.
//
//  WebSocketManager.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 06.01.25.
//

import Foundation
import MeetingServiceDTOs

/// A WebSocket manager service for handling real-time voting updates
class WebSocketService: ObservableObject {
   
   // MARK: - Properties
   
    private var webSocketTask: URLSessionWebSocketTask? /// The WebSocket task responsible for maintaining the connection
    private var urlSession: URLSession? /// The URLSession used to create the WebSocket connection
    
    @Published var liveStatus: String? /// Holds the latest live status message received from the WebSocket
    @Published var votingResults: GetVotingResultsDTO? /// Stores the voting results when they are received via WebSocket
    @Published var errorMessage: String? /// Holds any WebSocket-related error messages
    
   // MARK: - WebSocket Connection
   
   /// Establishes a WebSocket connection to receive live voting updates
    func connect(to votingId: UUID) {
       // Reset state before establishing a new connectio
       self.liveStatus = nil
       self.votingResults = nil
       self.errorMessage = nil
       
       // Retrieve the authentication token and configure URLSession with the authorization token
       if let token = UserDefaults.standard.string(forKey: "jwtToken") {
          let configuration = URLSessionConfiguration.default
          configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(token)"]
          self.urlSession = URLSession(configuration: configuration)
       } else {
          self.errorMessage = "Unauthorized: Token not found"
           return
       }
       
       // Construct the WebSocket URL
        guard let url = URL(string: "wss://kivop.ipv64.net/meetings/votings/\(votingId)/live-status") else {
            self.errorMessage = "Invalid URL"
            return
        }
        
       // Create and start the WebSocket connection
        webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()
        
       // Begin listening for incoming messages
        listenForMessages()
    }
    
   /// Closes the WebSocket connection gracefully
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
    }
    
   // MARK: - Message Handling
       
   /// Listens for incoming WebSocket messages
    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
               // Capture WebSocket errors
                DispatchQueue.main.async {
                    self.errorMessage = "WebSocket error: \(error.localizedDescription)"
                }
                
            case .success(let message):
               // Process the received message
                DispatchQueue.main.async {
                    self.handleMessage(message)
                }
                
               // Continue listening for more messages
                self.listenForMessages()
            }
        }
    }
    
   /// Processes the received WebSocket message
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
           // If the message contains an error, display it
            if text.starts(with: "ERROR:") {
                self.errorMessage = text
            } else {
               // Otherwise, treat it as a live status update
                self.liveStatus = text
            }
            
        case .data(let data):
           // Attempt to decode JSON-encoded voting results
            do {
                let decoder = JSONDecoder()
                let results = try decoder.decode(GetVotingResultsDTO.self, from: data)
                self.votingResults = results
                disconnect() // Disconnect after receiving results (one-time update)
            } catch {
               // Capture any decoding errors
                self.errorMessage = "Failed to decode voting results: \(error.localizedDescription)"
            }
            
        @unknown default:
           // Handle unexpected message types
            self.errorMessage = "Unknown message type received"
        }
    }
}
