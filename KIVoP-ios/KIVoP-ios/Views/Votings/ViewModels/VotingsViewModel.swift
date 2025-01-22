//
//  VotingsViewModel.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 22.01.25.
//

import Foundation
import Combine
import MapKit
import MeetingServiceDTOs
import SwiftUICore

@MainActor
class VotingsViewModel: ObservableObject {
   @ObservedObject private var meetingViewModel = MeetingViewModel()
   @Published var votings: [GetVotingDTO] = []
   // Ein Array aus Tupeln (meetingName, [(VotingsOfMeeting, ListSymbols)])
   @Published var groupedVotings: [(
      meetingName: String,
      votings: [(
         voting: GetVotingDTO,
         symbol: (status: String, color: Color)
      )]
   )] = []
   
   private var meetingVotingsMap: [GetMeetingDTO: [GetVotingDTO]] = [:]

    init() {
        Task {
            await fetchVotings()
        }
    }

    func fetchVotings() async {
        do {
           let fetchedVotings = try await VotingService.shared.fetchVotings()
            self.votings = fetchedVotings
           await fetchMeetings()
        } catch {
            print("Error fetching Votings: \(error)")
        }
    }

   private func fetchMeetings() async {
      for voting in votings {
         do {
            let meeting = try await meetingViewModel.fetchMeeting(byId: voting.meetingId)
            meetingVotingsMap[meeting] = votings.filter { $0.meetingId == meeting.id && $0.startedAt != nil}
         } catch {
            print("Error fetching meeting: \(error.localizedDescription)")
         }
      }
      groupeVotings()
   }
   
   func groupeVotings() {
      groupedVotings = meetingVotingsMap
         .sorted { $0.key.start > $1.key.start } // Sort meetings by start date
         .map { meeting, votings in
            let sortedVotings = votings
               .sorted { ($0.startedAt ?? Date.distantPast) > ($1.startedAt ?? Date.distantPast) } // Sort votings by startedAt
            
            let votingWithSymbols = sortedVotings.map { voting in
               (voting: voting, symbol: getSymbol(voting: voting))
            }
            
            let meetingName = meeting.status == .inSession ? "Aktuelle Sitzung (\(meeting.name))" : meeting.name
            
            return (meetingName: meetingName, votings: votingWithSymbols)
         }
   }
   
   func getSymbol(voting: GetVotingDTO) -> (status: String, color: Color) {
      if voting.iVoted {
         return ("checkmark", .blue)
      } else if voting.isOpen {
         return ("exclamationmark.arrow.trianglehead.counterclockwise.rotate.90", .orange)
      } else {
         return ("", .black)
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
