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

/// `VotingsViewModel` is responsible for managing the votings in the app
/// It fetches voting data, organizes it by meetings, and provides symbols for UI representation
@MainActor
class VotingsViewModel: ObservableObject {
   // MARK: - Properties
       
   /// ViewModel for fetching meetings
   @ObservedObject private var meetingViewModel = MeetingViewModel()
   /// Stores all fetched votings
   @Published var votings: [GetVotingDTO] = []
   /// Stores votings grouped by meeting names along with their UI symbols
   @Published var groupedVotings: [(
      meetingName: String,
      votings: [(
         voting: GetVotingDTO,
         symbol: (status: String, color: Color)
      )]
   )] = []
   
   /// Maps meetings to their corresponding votings
   private var meetingVotingsMap: [GetMeetingDTO: [GetVotingDTO]] = [:]

   // MARK: - Initialization
   /// Initializes the ViewModel and starts fetching votings asynchronously
    init() {
        Task {
            await fetchVotings()
        }
    }
   
   // MARK: - Fetching Votings
   /// Fetches all votings asynchronously from `VotingService`
    func fetchVotings() async {
        do {
           let fetchedVotings = try await VotingService.shared.fetchVotings()
            self.votings = fetchedVotings
           await fetchMeetings() // fetch meetings after votings are fetched
        } catch {
            print("Error fetching Votings: \(error)")
        }
    }

   // MARK: - Fetching Meetings
   /// Fetches meetings for each voting and maps them to their corresponding votings
   private func fetchMeetings() async {
      for voting in votings {
         do {
            let meeting = try await meetingViewModel.fetchMeeting(byId: voting.meetingId)
            // Filters out votings that have a valid `startedAt` date before adding them to the map
            meetingVotingsMap[meeting] = votings.filter { $0.meetingId == meeting.id && $0.startedAt != nil}
         } catch {
            print("Error fetching meeting: \(error.localizedDescription)")
         }
      }
      groupeVotings() // group votings after fetching meetings
   }
   
   // MARK: - Grouping Votings
   /// Groups votings by their meeting, sorts meetings by start date, and assigns UI symbols
   func groupeVotings() {
      groupedVotings = meetingVotingsMap
         .sorted { $0.key.start > $1.key.start } // Sorts meetings by start date (most recent first)
         .map { meeting, votings in
            let sortedVotings = votings
               .sorted { ($0.startedAt ?? Date.distantPast) > ($1.startedAt ?? Date.distantPast) } // Sort votings by startedAt
            
            let votingWithSymbols = sortedVotings.map { voting in
               (voting: voting, symbol: getSymbol(voting: voting))
            }
            
            // If the meeting is ongoing, prepend "Aktuelle Sitzung" to the name
            let meetingName = meeting.status == .inSession ? "Aktuelle Sitzung (\(meeting.name))" : meeting.name
            
            return (meetingName: meetingName, votings: votingWithSymbols)
         }
   }
   
   // MARK: - Voting Symbols
   /// Determines the appropriate UI symbol and color for a voting status
   func getSymbol(voting: GetVotingDTO) -> (status: String, color: Color) {
      if voting.iVoted {
         return ("checkmark", .blue) // User has voted
      } else if voting.isOpen {
         return ("exclamationmark.arrow.trianglehead.counterclockwise.rotate.90", .orange) // Voting is still open and user hasn't voted
      } else {
         return ("", .black) // Voting is closed and user did not vote
      }
   }
   
}



// MARK: - Mock Data (Used for Previews & Testing)

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
