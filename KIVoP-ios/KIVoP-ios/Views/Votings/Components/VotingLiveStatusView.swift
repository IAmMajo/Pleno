// This file is licensed under the MIT-0 License.
//
//  VotingLiveStatusView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 06.01.25.
//

import SwiftUI
import MeetingServiceDTOs

struct VotingLiveStatusView: View {
   @StateObject private var webSocketService: WebSocketService
   let votingId: UUID
   let votingResults: GetVotingResultsDTO
   
   var onWebSocketError: (() -> Void)? // Callback for error handling
   
   @State private var value: Int = 0
   @State private var total: Int = 0
   @State private var progress: Double = 0
   
   init(votingId: UUID, onWebSocketError: (() -> Void)? = nil) {
      self.votingId = votingId
      _webSocketService = StateObject(wrappedValue: WebSocketService())
      self.onWebSocketError = onWebSocketError
      self.votingResults = mockVotingResults
   }
   
   var body: some View {
      VStack {
         if let liveStatus = webSocketService.liveStatus {
            VStack {
               ZStack {
                  Circle()
                     .stroke(
                        .blue.opacity(0.3),
                        lineWidth: 35
                     )
                     .overlay (
                        Text("\(liveStatus)")
//                        Text("2/4")
                           .tracking(5)
                           .font(.system(size: 50))
                           .fontWeight(.bold)
                           .foregroundStyle(Color(UIColor.label).opacity(0.6).mix(with: Color.blue, by: 0.5))
                     )
                  Circle()
                     .trim(from: 0, to: progress) // updated es sich? ändern zu @State ?
                     .stroke(
                        .blue,
                        style: StrokeStyle(
                           lineWidth: 35,
                           lineCap: .round
                        )
                     )
                     .rotationEffect(.degrees(-90))
                     .animation(.easeOut(duration: 0.8), value: progress)
               }
               .padding(30)
               
               Text("Es haben \(value) von \(total) Personen abgestimmt.")
                  .foregroundStyle(Color(UIColor.label).opacity(0.6))
            }
         }
         
         if let votingResults = webSocketService.votingResults {
            Text("Voting Results: \(votingResults)")
               .font(.headline)
               .padding()
         }
         
         if let errorMessage = webSocketService.errorMessage {
            Text("Error: \(errorMessage)")
               .foregroundColor(.red)
               .onAppear {
                  onWebSocketError?() // Trigger callback when an error occurs
               }
         }
      }
      .onAppear {
         webSocketService.connect(to: votingId)
      }
      .onDisappear {
         webSocketService.disconnect()
      }
      .onChange(of: webSocketService.liveStatus) { old, newLiveStatus in
         guard let newLiveStatus = newLiveStatus else { return }
         setValueTotalProgress(liveStatus: newLiveStatus)
      }
   }
   
   private func setValueTotalProgress(liveStatus: String) {
      let liveStatusSplit = liveStatus.split(separator: "/")
      self.value = Int(liveStatusSplit[0]) ?? 0
      self.total = Int(liveStatusSplit[1]) ?? 0
      withAnimation(.easeOut(duration: 0.8)) {
         self.progress = Double(value) / Double(total)
      }
   }
   
}

#Preview {
   VotingLiveStatusView(votingId: UUID(uuidString: "1A21089E-58EC-4B43-87E0-873D1743E14D")!)
}
