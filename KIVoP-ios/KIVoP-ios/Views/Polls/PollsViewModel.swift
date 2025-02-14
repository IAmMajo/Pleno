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
//  PollsViewModel.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 23.01.25.
//

import Foundation
import Combine
import MapKit
import PollServiceDTOs
import SwiftUICore

/// ViewModel responsible for fetching and managing polls
/// Conforms to `ObservableObject` to allow SwiftUI to react to state changes
@MainActor
class PollsViewModel: ObservableObject {
   // Holds a list of polls with their respective UI symbols
   @Published var polls: [(poll: GetPollDTO, symbol: (status: String, color: Color))] = []
   
   // Initializes the ViewModel and immediately fetches polls asynchronously
    init() {
        Task {
            await fetchPolls()
        }
    }

   // Fetches all polls asynchronously from the `PollAPI` service
   func fetchPolls() async {
      PollAPI.shared.fetchAllPolls { [weak self] result in
         DispatchQueue.main.async {
            guard let self = self else { return }
            switch result {
            case .success(let polls):
               self.polls = polls.map { poll in
                  (poll: poll, symbol: self.getSymbol(poll: poll)) // Assigns a UI symbol for each poll
               }
            case .failure(let error):
               print("Error loading polls: \(error.localizedDescription)")
            }
         }
      }
   }
   
   // Determines the appropriate UI symbol and color for a poll's status
   // - Returns: A tuple containing the system symbol name and color
   func getSymbol(poll: GetPollDTO) -> (status: String, color: Color) {
      if poll.iVoted {
         return ("checkmark", .blue) // User has already voted
      } else if poll.isOpen {
         return ("exclamationmark.arrow.trianglehead.counterclockwise.rotate.90", .orange) // Poll is still open
      } else {
         return ("", .black) // Poll is closed and user did not vote
      }
   }
   
}


// MARK: - mock data for preview and testing

var mockPollResults: GetPollResultsDTO {
   return GetPollResultsDTO(
      myVotes: [0], // Index 0: Abstention | nil: did not vote at all
      totalCount: 50,
      identityCount: 25,
      results: [mockPollResult0]
   )
}

var mockPollResult0: GetPollResultDTO {
   return GetPollResultDTO(
      index: 1,
      text: "Option",
      count: 5,
      percentage: 10,
      identities: []
   )
}
