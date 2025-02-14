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

//
//  VotingLiveStatusView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 06.01.25.
//

import SwiftUI
import MeetingServiceDTOs

/// A view that displays the live status of an ongoing voting process using a WebSocket
struct VotingLiveStatusView: View {
   
   // MARK: - Properties
   
   @StateObject private var webSocketService: WebSocketService /// WebSocket service responsible for fetching live voting updates
   let votingId: UUID /// The unique identifier of the voting session
   let votingResults: GetVotingResultsDTO /// Stores the voting results
   
   var onWebSocketError: (() -> Void)? // Callback for handling WebSocket errors
   
   // MARK: - State Variables
   
   @State private var value: Int = 0 /// The number of votes already cast
   @State private var total: Int = 0 /// The total number of eligible voters
   @State private var progress: Double = 0 /// The progress of the voting process as a fraction (between 0 and 1)
   
   // MARK: - Initializer
   /// Initializes the `VotingLiveStatusView` with the given `votingId`
   ///   - onWebSocketError: A callback function that gets triggered when a WebSocket error occurs
   init(votingId: UUID, onWebSocketError: (() -> Void)? = nil) {
      self.votingId = votingId
      _webSocketService = StateObject(wrappedValue: WebSocketService())
      self.onWebSocketError = onWebSocketError
      self.votingResults = mockVotingResults
   }
   
   // MARK: - Body
   var body: some View {
      VStack {
         // MARK: - Live Status Circle (if live status is available)
         if let liveStatus = webSocketService.liveStatus {
            VStack {
               ZStack {
                  // Background Circle
                  Circle()
                     .stroke(
                        .blue.opacity(0.3), // Light blue background circle
                        lineWidth: 35
                     )
                     .overlay (
                        Text("\(liveStatus)") // Displays live status in the center
                           .tracking(5)
                           .font(.system(size: 50))
                           .fontWeight(.bold)
                           .foregroundStyle(Color(UIColor.label).opacity(0.6).mix(with: Color.blue, by: 0.5))
                     )
                  
                  // Foreground Progress Circle (updates dynamically)
                  Circle()
                     .trim(from: 0, to: progress) // Adjusts dynamically based on voting progress
                     .stroke(
                        .blue, // Foreground circle indicating progress
                        style: StrokeStyle(
                           lineWidth: 35,
                           lineCap: .round
                        )
                     )
                     .rotationEffect(.degrees(-90)) // Rotates to start from top
                     .animation(.easeOut(duration: 0.8), value: progress) // Smooth transition
               }
               .padding(30)
               
               // Voting progress text below the circle
               Text("Es haben \(value) von \(total) Personen abgestimmt.")
                  .foregroundStyle(Color(UIColor.label).opacity(0.6))
            }
         }
         
         // MARK: - Voting Results Display (if available)
         if let votingResults = webSocketService.votingResults {
            Text("Voting Results: \(votingResults)")
               .font(.headline)
               .padding()
         }
         
         // MARK: - Error Handling
         if let errorMessage = webSocketService.errorMessage {
            Text("Error: \(errorMessage)")
               .foregroundColor(.red)
               .onAppear {
                  onWebSocketError?() // Trigger callback when an error occurs
               }
         }
      }
      .onAppear {
         webSocketService.connect(to: votingId) // Connects to WebSocket when view appears
      }
      .onDisappear {
         webSocketService.disconnect() // Disconnects WebSocket when view disappears
      }
      .onChange(of: webSocketService.liveStatus) { old, newLiveStatus in
         guard let newLiveStatus = newLiveStatus else { return }
         setValueTotalProgress(liveStatus: newLiveStatus) // Updates progress when live status changes
      }
   }
   
   // MARK: - Helper Functions
   /// Updates the vote count, total count, and progress percentage based on live status
   /// - Parameter liveStatus: A string in the format "currentVotes/totalVotes"
   private func setValueTotalProgress(liveStatus: String) {
      let liveStatusSplit = liveStatus.split(separator: "/")
      self.value = Int(liveStatusSplit[0]) ?? 0 // Extracts number of votes cast
      self.total = Int(liveStatusSplit[1]) ?? 0 // Extracts total number of voters
      withAnimation(.easeOut(duration: 0.8)) {
         self.progress = Double(value) / Double(total) // Updates progress
      }
   }
   
}
