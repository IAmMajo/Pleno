//
//  WebSocketManager.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 06.01.25.
//

import Foundation
import MeetingServiceDTOs

class WebSocketManager: ObservableObject {
   @Published var liveStatus: String? // Holds the live status (e.g., "3/10")
   @Published var votingResults: GetVotingResultsDTO? // Holds the final results when voting ends
   @Published var errorMessage: String? // Holds any error messages
   
   private var webSocketTask: URLSessionWebSocketTask?
   private let urlSession = URLSession(configuration: .default)
   
   func connect(toVotingId id: UUID) {
      let url = URL(string: "wss://kivop.ipv64.net/meetings/votings/\(id)/live-status")!
      webSocketTask = urlSession.webSocketTask(with: url)
      webSocketTask?.resume()
      listenForMessages()
   }
   
   func disconnect() {
      webSocketTask?.cancel(with: .goingAway, reason: nil)
      webSocketTask = nil
   }
   
   private func listenForMessages() {
      webSocketTask?.receive { [weak self] result in
         guard let self = self else { return }
         
         switch result {
         case .success(let message):
            switch message {
            case .string(let text):
               if text.hasPrefix("ERROR:") {
                  DispatchQueue.main.async {
                     self.errorMessage = text
                  }
               } else {
                  DispatchQueue.main.async {
                     self.liveStatus = text
                  }
               }
            case .data(let binaryData):
               do {
                  let results = try JSONDecoder().decode(GetVotingResultsDTO.self, from: binaryData)
                  DispatchQueue.main.async {
                     self.votingResults = results
                     self.disconnect() // Close the connection when voting ends
                  }
               } catch {
                  DispatchQueue.main.async {
                     self.errorMessage = "Failed to decode voting results."
                  }
               }
            @unknown default:
               DispatchQueue.main.async {
                  self.errorMessage = "Received unknown message type."
               }
            }
         case .failure(let error):
            DispatchQueue.main.async {
               self.errorMessage = "WebSocket error: \(error.localizedDescription)"
            }
         }
         
         // Continue listening for more messages
         self.listenForMessages()
      }
   }
}
