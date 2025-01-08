//
//  Votings_VotingRowView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 28.11.24.
//

import SwiftUI
import MeetingServiceDTOs

struct Votings_VotingRowView: View {
//   @StateObject private var webSocketService = WebSocketService()
   @ObservedObject var viewModel: VotingViewModel
   @State var symbolColor: Color = .black
   @State var status: String = ""
   
       var onVotingSelected: (GetVotingDTO) -> Void

       var body: some View {
           HStack {
               Text(viewModel.voting.question)
                   .frame(maxWidth: .infinity, alignment: .leading)
               Spacer()
              if viewModel.status != "" {
                 Image(systemName: viewModel.status)
                    .foregroundStyle(viewModel.symbolColor)
              }
               Spacer()
           }
           .contentShape(Rectangle())
           .onTapGesture {
               onVotingSelected(viewModel.voting)
           }
           .task {
               await viewModel.loadSymbolColorAndStatus()
//              await loadSymbolColorAndStatus(votingId: viewModel.voting.id)
           }
           .onChange(of: viewModel.voting.isOpen) { old, newValue in
              Task {
                 print("RowView: viewModel.voting changed")
                 await viewModel.loadSymbolColorAndStatus()
//                 await loadSymbolColorAndStatus(votingId: viewModel.voting.id)
              }
           }
       }
   
//   private func loadSymbolColorAndStatus(votingId: UUID) async {
//      await withCheckedContinuation { continuation in
//         webSocketService.connect(to: votingId)
//         
//         // Wait for the WebSocket to receive messages
//         DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
////            print("liveStatus: \(webSocketService.liveStatus ?? "")")
////            print("votingResults: \(String(describing: webSocketService.votingResults))")
////            print("errorMessage: \(webSocketService.errorMessage ?? "")")
//            if let liveStatus = self.webSocketService.liveStatus, !liveStatus.isEmpty {
//               self.webSocketService.disconnect()
//               self.symbolColor = .blue
//               self.status = "checkmark"
//               continuation.resume()
//            } else if self.webSocketService.votingResults != nil {
//               self.webSocketService.disconnect()
//               continuation.resume()
//            } else if self.webSocketService.errorMessage != nil {
//               let error = self.webSocketService.errorMessage!
//               self.webSocketService.disconnect()
//               
//               if error.contains("Voting is closed") {
//                  print("YAY Voting is closed")
//                  VotingService.shared.fetchVotingResults(votingId: votingId) { result in
//                     DispatchQueue.main.async {
//                        switch result {
//                        case .success(let results):
//                           if results.myVote != nil { //hasVoted
//                              self.symbolColor = .blue
//                              self.status = "checkmark"
//                           } else {
//                              self.symbolColor = .black
//                              self.status = ""
//                           }
//                        case .failure(let error):
//                           print("Fehler beim Abrufen der Ergebnisse: \(error.localizedDescription)")
//                        }
//                     }
//                  }
//               } else if error.contains("You must vote on this voting first") {
//                  print("YAY You must vote on this voting first")
//                  self.symbolColor = .orange
//                  self.status = "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90"
//               }
//               continuation.resume()
//            } else {
//               self.webSocketService.disconnect()
//               continuation.resume()
//            }
//         }
//      }
//   }
}

//#Preview {
//   Votings_VotingRowView(viewModel: <#VotingViewModel#>, onVotingSelected: <#(GetVotingDTO) -> Void#>)
//}
