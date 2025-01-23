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

@MainActor
class PollsViewModel: ObservableObject {
   @Published var polls: [(poll: GetPollDTO, symbol: (status: String, color: Color))] = []
   
    init() {
        Task {
            await fetchPolls()
        }
    }

   func fetchPolls() async {
      PollAPI.shared.fetchAllPolls { [weak self] result in
         DispatchQueue.main.async {
            guard let self = self else { return }
            switch result {
            case .success(let polls):
               self.polls = polls.map { poll in
                  (poll: poll, symbol: self.getSymbol(poll: poll))
               }
            case .failure(let error):
               print("Error loading polls: \(error.localizedDescription)")
            }
         }
      }
   }
   
   func getSymbol(poll: GetPollDTO) -> (status: String, color: Color) {
      if poll.iVoted {
         return ("checkmark", .blue)
      } else if poll.isOpen {
         return ("exclamationmark.arrow.trianglehead.counterclockwise.rotate.90", .orange)
      } else {
         return ("", .black)
      }
   }
   
}



public struct Poll: Identifiable, Codable, Hashable {
   public let id: UUID
   public let question: String
   public let description: String
   public let multipleSelection: Bool
   public var isOpen: Bool
   public var startedAt: Date?
   public var expirationDate: Date
   public var options: [PollOption]
}

public struct PollOption: Codable, Hashable {
   public let index: UInt8
   public var text: String
}

public struct PollResults: Codable, Hashable {
   public var votingId: UUID
   public var myVote: UInt8? // Index 0: Abstention | nil: did not vote at all
   public var totalCount: UInt
   public var results: [PollResult]
}

public struct PollResult: Identifiable, Codable, Hashable {
   public var id = UUID()
   public var index: UInt8 // Index 0: Abstention
   public var count: UInt
   public var percentage: Double
   public var identities: [GetIdentityDTO]?
}



var mockPolls: [Poll] {
   return [
      Poll(
         id: UUID(),
         question: "Welche Brötchen soll es fürs Frühstück geben?",
         description: "Für das gemeinschaftliche Frühstücken soll eine Brötchenwahl stattfinden, damit vorher genug eingekauft werden kann.",
         multipleSelection: true,
         isOpen: true,
         startedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
         expirationDate: Calendar.current.date(byAdding: .day, value: +10, to: Date())!,
         options: mockPollOptions1
      ),
      Poll(
         id: UUID(),
         question: "Welche Option sollen gewählt werden?",
         description: "Dies ist die Beschreibung einer Umfrage ohne Mehrfachauswahl.",
         multipleSelection: false,
         isOpen: true,
         startedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
         expirationDate: Calendar.current.date(byAdding: .hour, value: +10, to: Date())!,
         options: mockPollOptions2
      ),
      Poll(
         id: UUID(),
         question: "Welche Optionen sollen gewählt werden?",
         description: "Dies ist die Beschreibung einer Umfrage mit Mehrfachauswahl.",
         multipleSelection: true,
         isOpen: false,
         startedAt: Calendar.current.date(byAdding: .day, value: -15, to: Date())!,
         expirationDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
         options: mockPollOptions2
      )
   ]
}

let mockPollOptions1: [PollOption] = [
   PollOption(index: 0, text: "Enthaltung"),
   PollOption(index: 1, text: "Weizenbrötchen"),
   PollOption(index: 2, text: "Vollkornbrötchen"),
   PollOption(index: 3, text: "Milchbrötchen"),
]

let mockPollOptions2: [PollOption] = [
   PollOption(index: 0, text: "Enthaltung"),
   PollOption(index: 1, text: "Option1"),
   PollOption(index: 2, text: "Option2"),
   PollOption(index: 3, text: "Option3"),
   PollOption(index: 4, text: "Option4"),
]


//var mockPollResults: PollResults {
//   return PollResults(
//      votingId: mockVotings[0].id,
//      myVote: nil, // Index 0: Abstention | nil: did not vote at all
//      totalCount: 50,
//      results: [mockPollResult1, mockPollResult2, mockPollResult3, mockPollResult4]
//   )
//}

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

var mockPollResult1: PollResult {
   return PollResult(
      index: 0, // Index 0: Abstention
      count: 2,
      percentage: 2,
      identities: []
   )
}
var mockPollResult2: PollResult {
   return PollResult(
      index: 1, // Index 0: Abstention
      count: 8,
      percentage: 8,
      identities: []
   )
}
var mockPollResult3: PollResult {
   return PollResult(
      index: 2, // Index 0: Abstention
      count: 10,
      percentage: 10,
      identities: [/*mockIdentity1*/]
   )
}
var mockPollResult4: PollResult {
   return PollResult(
      index: 3, // Index 0: Abstention
      count: 30,
      percentage: 30,
      identities: [/*mockIdentity1, mockIdentity2*/]
   )
}
var mockPollResult5: PollResult {
   return PollResult(
      index: 4, // Index 0: Abstention
      count: 30,
      percentage: 30,
      identities: []
   )
}
var mockPollResult6: PollResult {
   return PollResult(
      index: 5, // Index 0: Abstention
      count: 30,
      percentage: 30,
      identities: []
   )
}
