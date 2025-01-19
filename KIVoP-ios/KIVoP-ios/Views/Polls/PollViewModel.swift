//
//  PollsViewModel.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 17.01.25.
//

import Foundation
import SwiftUI
import MeetingServiceDTOs

@MainActor
class PollViewModel: ObservableObject, Identifiable {
   let id: UUID
   @Published var pollDTO: Poll
   @Published var symbolColor: Color = .black
   @Published var statusSymbol: String = ""
   let hasVoted: Bool
      
   init(poll: Poll) {
      self.id = poll.id
      self.pollDTO = poll
      self.hasVoted = VotingStateTracker.hasVoted(for: poll.id)
      Task {
         await loadStatus()
      }
   }
   
   func update(pollDTO: Poll) {
      if self.pollDTO != pollDTO {
         self.pollDTO = pollDTO
      } else if !pollDTO.isOpen {
         self.pollDTO = pollDTO
         Task {
            await loadStatus()
         }
      }
   }
   
   func refreshAfterVote() async {
      if PollStateTracker.hasVotedForPoll(for: pollDTO.id) {
              DispatchQueue.main.async {
                  self.symbolColor = .blue
                  self.statusSymbol = "checkmark"
              }
          } else {
              print("No vote found for voting ID: \(self.id)")
          }
   }
   
   func loadStatus() async {
      VotingService.shared.fetchVotingResults(votingId: pollDTO.id) { results in
         DispatchQueue.main.async {
            switch results {
            case .success(let results):
               if results.myVote != nil {
                  self.symbolColor = .blue
                  self.statusSymbol = "checkmark"
               } else {
                  self.symbolColor = self.pollDTO.isOpen ? .orange : .black
                  self.statusSymbol = self.pollDTO.isOpen ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : ""
               }
            case .failure(_ /*let error*/):
               //                   print("Fehler beim Abrufen der Ergebnisse: \(error.localizedDescription)")
               if self.hasVoted {
                  self.symbolColor = .blue
                  self.statusSymbol = "checkmark"
               } else {
                  self.symbolColor = self.pollDTO.isOpen ? .orange : .black
                  self.statusSymbol = self.pollDTO.isOpen ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : ""
               }
            }
         }
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


var mockPollResults: PollResults {
   return PollResults(
      votingId: mockVotings[0].id,
      myVote: nil, // Index 0: Abstention | nil: did not vote at all
      totalCount: 50,
      results: [mockPollResult1, mockPollResult2, mockPollResult3, mockPollResult4]
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
