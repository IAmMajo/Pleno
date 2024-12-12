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
      isLoading = true
      do {
         let results = try await APIService.shared.fetchVotingResults(by: voting.id)
         if results.myVote != nil {
            symbolColor = .blue
            status = "checkmark"
         } else {
            symbolColor = voting.isOpen ? .orange : .black
            status = voting.isOpen ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : ""
         }
      } catch {
         print("Error loading voting results: \(error)")
         if hasVoted {
            symbolColor = .blue
            status = "checkmark"
         } else {
            symbolColor = voting.isOpen ? .orange : .black
//            print("symbolColor: \(symbolColor)")
            status = voting.isOpen ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : ""
//            print("status: \(status)")
         }
      }
      isLoading = false
   }
}
