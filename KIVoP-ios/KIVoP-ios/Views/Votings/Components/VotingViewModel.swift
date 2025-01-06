//
//  VotingViewModel.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 28.11.24.
//

import SwiftUI
import MeetingServiceDTOs

@MainActor
class VotingViewModel: ObservableObject, Identifiable {
   let voting: GetVotingDTO
   @Published var symbolColor: Color = .black
   @Published var status: String = ""
   @Published var isLoading: Bool = false
   let hasVoted: Bool
   
   init(voting: GetVotingDTO) {
      self.voting = voting
      self.hasVoted = VotingStateTracker.hasVoted(for: voting.id)
   }
   
   func loadSymbolColorAndStatus() async {
      VotingService.shared.fetchVotingResults(votingId: voting.id) { result in
         DispatchQueue.main.async {
            switch result {
            case .success(let results):
               if results.myVote != nil {
                  self.symbolColor = .blue
                  self.status = "checkmark"
               } else {
                  self.symbolColor = self.voting.isOpen ? .orange : .black
                  self.status = self.voting.isOpen ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : ""
               }
            case .failure(_ /*let error*/):
               //                   print("Fehler beim Abrufen der Ergebnisse: \(error.localizedDescription)")
               if self.hasVoted {
                  self.symbolColor = .blue
                  self.status = "checkmark"
               } else {
                  self.symbolColor = self.voting.isOpen ? .orange : .black
      //            print("symbolColor: \(symbolColor)")
                  self.status = self.voting.isOpen ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : ""
      //            print("status: \(status)")
               }
            }
         }
      }
   }
}
