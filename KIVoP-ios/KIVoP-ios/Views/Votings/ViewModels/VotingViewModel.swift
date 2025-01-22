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
   let id: UUID
   @Published var votingDTO: GetVotingDTO
   @Published var groupedVotings: [(String, [VotingViewModel])] = []
   @Published var symbolColor: Color = .black
   @Published var statusSymbol: String = ""
   @Published var meeting: GetMeetingDTO?
//   let hasVoted: Bool
   
   @ObservedObject private var meetingViewModel: MeetingViewModel
   
   init(voting: GetVotingDTO, meetingViewModel: MeetingViewModel) {
      self.id = voting.id
      self.votingDTO = voting
//      self.hasVoted = VotingStateTracker.hasVoted(for: voting.id)
      self.meetingViewModel = meetingViewModel
      Task {
         await loadMeeting()
         await loadStatus()
      }
   }
   
   func update(votingDTO: GetVotingDTO) {
      if self.votingDTO != votingDTO {
         self.votingDTO = votingDTO
      } else if !votingDTO.isOpen {
         self.votingDTO = votingDTO
         Task {
            await loadMeeting()
            await loadStatus()
         }
      }
   }
   
   func refreshAfterVote() async {
      DispatchQueue.main.async {
          self.symbolColor = .blue
          self.statusSymbol = "checkmark"
      }
      if VotingStateTracker.hasVoted(for: votingDTO.id) {
              DispatchQueue.main.async {
                  self.symbolColor = .blue
                  self.statusSymbol = "checkmark"
              }
          } else {
              print("No vote found for voting ID: \(self.id)")
          }
   }
   
   private func loadMeeting() async {
      do {
         self.meeting = try await meetingViewModel.fetchMeeting(byId: votingDTO.meetingId)
      } catch {
         print("Error fetching meeting: \(error.localizedDescription)")
      }
   }
   
   func loadStatus() async {
      VotingService.shared.fetchVotingResults(votingId: votingDTO.id) { results in
         DispatchQueue.main.async {
            switch results {
            case .success(let results):
               if results.myVote != nil {
                  self.symbolColor = .blue
                  self.statusSymbol = "checkmark"
               } else {
                  self.symbolColor = self.votingDTO.isOpen ? .orange : .black
                  self.statusSymbol = self.votingDTO.isOpen ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : ""
               }
            case .failure(_ /*let error*/):
               //                   print("Fehler beim Abrufen der Ergebnisse: \(error.localizedDescription)")
               if self.votingDTO.iVoted {
                  self.symbolColor = .blue
                  self.statusSymbol = "checkmark"
               } else {
                  self.symbolColor = self.votingDTO.isOpen ? .orange : .black
                  self.statusSymbol = self.votingDTO.isOpen ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : ""
               }
            }
         }
      }
   }
}

var mockVotings: [GetVotingDTO] {
   return [
      GetVotingDTO(
         id: UUID(),
         meetingId: mockMeeting1.id,
         question: "Welche Farbe soll die neue Vereinsfarbe werden?",
         description: "Der Verein braucht eine neue Vereinsfarbe, welche gut zum Verein passt.",
         isOpen: true,
         startedAt: Date.now,
         closedAt: nil,
         anonymous: false, iVoted: false,
         options: mockOptions1
      ),
      GetVotingDTO(
         id: UUID(),
         meetingId: mockMeeting2.id,
         question: "Welche Option soll gewählt werden 4?",
         description: "Beschreibung4",
         isOpen: false,
         startedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
         closedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
         anonymous: false, iVoted: true,
         options: mockOptions2
      ),
      GetVotingDTO(
         id: UUID(),
         meetingId: mockMeeting1.id,
         question: "Welche Option soll gewählt werden 2?",
         description: "Beschreibung2",
         isOpen: false,
         startedAt: Calendar.current.date(byAdding: .minute, value: -15, to: Date())!,
         closedAt: Calendar.current.date(byAdding: .minute, value: -5, to: Date())!,
         anonymous: false, iVoted: false,
         options: mockOptions2
      ),
      GetVotingDTO(
         id: UUID(),
         meetingId: mockMeeting1.id,
         question: "Welche Option soll gewählt werden 3?",
         description: "Beschreibung3",
         isOpen: false,
         startedAt: Calendar.current.date(byAdding: .minute, value: -35, to: Date())!,
         closedAt: Calendar.current.date(byAdding: .minute, value: -15, to: Date())!,
         anonymous: false, iVoted: true,
         options: mockOptions2
      ),
   ]
}

let mockOptions1: [GetVotingOptionDTO] = [
   GetVotingOptionDTO(index: 0, text: "Enthaltung"),
   GetVotingOptionDTO(index: 1, text: "Rot"),
   GetVotingOptionDTO(index: 2, text: "Grün"),
   GetVotingOptionDTO(index: 3, text: "Blau"),
]

let mockOptions2: [GetVotingOptionDTO] = [
   GetVotingOptionDTO(index: 0, text: "Enthaltung"),
   GetVotingOptionDTO(index: 1, text: "Option1"),
   GetVotingOptionDTO(index: 2, text: "Option2"),
   GetVotingOptionDTO(index: 3, text: "Option3"),
   GetVotingOptionDTO(index: 4, text: "Option4"),
]

var mockMeetings: [GetMeetingDTO] {
   return [mockMeeting1, mockMeeting2]
}

let mockMeeting1: GetMeetingDTO = GetMeetingDTO(
   id: UUID(),
   name: "Jahreshauptversammlung",
   description: "Das ist die Jahreshauptversammlung",
   status: MeetingStatus.inSession,
   start: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!,
   duration: nil,
   location: nil,
   chair: nil,
   code: nil
   )

let mockMeeting2: GetMeetingDTO = GetMeetingDTO(
   id: UUID(),
   name: "Sitzung2",
   description: "Das ist eine Sitzung2",
   status: MeetingStatus.completed,
   start: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
   duration: 60,
   location: nil,
   chair: nil,
   code: nil
   )

var mockVotingResults: GetVotingResultsDTO {
   return GetVotingResultsDTO(
      votingId: mockVotings[0].id,
      myVote: nil, // Index 0: Abstention | nil: did not vote at all
      results: [mockVotingResult1, mockVotingResult2, mockVotingResult3, mockVotingResult4]
   )
}

var mockVotingResult1: GetVotingResultDTO {
   return GetVotingResultDTO(
      index: 0, // Index 0: Abstention
      count: 2,
      percentage: 2,
      identities: []
   )
}
var mockVotingResult2: GetVotingResultDTO {
   return GetVotingResultDTO(
      index: 1, // Index 0: Abstention
      count: 8,
      percentage: 8,
      identities: []
   )
}
var mockVotingResult3: GetVotingResultDTO {
   return GetVotingResultDTO(
      index: 2, // Index 0: Abstention
      count: 10,
      percentage: 10,
      identities: []
   )
}
var mockVotingResult4: GetVotingResultDTO {
   return GetVotingResultDTO(
      index: 3, // Index 0: Abstention
      count: 30,
      percentage: 30,
      identities: []
   )
}


let mockIdentity: GetIdentityDTO = GetIdentityDTO(id: UUID(), name: "Max Mustermann")
