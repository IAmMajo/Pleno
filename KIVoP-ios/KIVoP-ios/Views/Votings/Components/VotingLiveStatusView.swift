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
   @State var votingResults: GetVotingResultsDTO
   
   init(votingId: UUID) {
      self.votingId = votingId
      _webSocketService = StateObject(wrappedValue: WebSocketService())
      self.votingResults = VotingsView().mockVotingResults
   }
   
   var body: some View {
      VStack {
         if let liveStatus = webSocketService.liveStatus {
            Text("Live Status: \(liveStatus)")
               .font(.title)
               .padding()
         }
         
         if let votingResults = webSocketService.votingResults {
//            Text("Voting Results: \(self.votingResults)")
//               .font(.headline)
//               .padding()
//            List{
//               Section {
//                  ForEach (self.votingResults.results, id: \.self) { result in
//                     HStack {
//                        Image(systemName: self.votingResults.myVote == result.index ? "checkmark.circle.fill" : "circle.fill")
//                       
//                        Spacer()
//                        Text("\(result.percentage, specifier: "%.2f")%")
//                           .opacity(0.6)
//                     }
//                  }
//               } header: {
//                  Spacer(minLength: 0).listRowInsets(EdgeInsets())
//               }
//            }
//            .onAppear() {
//               self.votingResults = votingResults
//            }
         }
         
         if let errorMessage = webSocketService.errorMessage {
            Text("Error: \(errorMessage)")
               .foregroundColor(.red)
         }
      }
      .onAppear {
         webSocketService.connect(to: votingId)
//         DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            print("liveStatus: \(webSocketService.liveStatus ?? "")")
//            print("votingResults: \(String(describing: webSocketService.votingResults))")
//            print("errorMessage: \(webSocketService.errorMessage ?? "")")
//         }
      }
      .onDisappear {
         webSocketService.disconnect()
      }
   }
}

#Preview {
   VotingLiveStatusView(votingId: UUID(uuidString: "")!)
}
