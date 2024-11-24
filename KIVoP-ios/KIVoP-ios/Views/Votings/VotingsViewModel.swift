//
//  VotingsViewModel.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 24.11.24.
//

import Foundation
import MeetingServiceDTOs

@MainActor

class VotingsViewModel: ObservableObject {
   @Published var votings: [GetVotingDTO] = []
   @Published var errorMessage: String? = nil
   @Published var isLoading = false
   
   func fetchVotings() {
      isLoading = true
      errorMessage = nil
      
//      APIService.shared.fetchAllVotings { [weak self] result in
//         DispatchQueue.main.async {
//            self?.isLoading = false
//            switch result {
//            case .success(let votings):
//               self?.votings = votings
//               self?.votings = [
//                  GetVotingDTO(
//                     id: UUID(),
//                     meetingId: UUID(),
//                     question: "Frage",
//                     isOpen: true,
//                     startedAt: Date.now,
//                     closedAt: nil,
//                     anonymous: false,
//                     options: [
//                        GetVotingOptionDTO(votingId: UUID(), index: 0, text: "Option 1"),
//                        GetVotingOptionDTO(votingId: UUID(), index: 1, text: "Option 2")
//                     ]
//                  ),
//                  GetVotingDTO(
//                     id: UUID(),
//                     meetingId: UUID(),
//                     question: "Frage2",
//                     isOpen: false,
//                     startedAt: Date.distantPast,
//                     closedAt: Date.distantPast,
//                     anonymous: false,
//                     options: [
//                        GetVotingOptionDTO(votingId: UUID(), index: 0, text: "Option 1"),
//                        GetVotingOptionDTO(votingId: UUID(), index: 1, text: "Option 2"),
//                        GetVotingOptionDTO(votingId: UUID(), index: 2, text: "Option 3")
//                     ]
//                  )
//               ]
//            case .failure(let error):
//               self?.errorMessage = error.localizedDescription
//            }
//         }
//      }
   }
}
