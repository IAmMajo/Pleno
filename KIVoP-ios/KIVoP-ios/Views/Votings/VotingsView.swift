//
//  Votings-VotingsOverview.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 08.11.24.
//

import SwiftUI
import MeetingServiceDTOs

// SampleData
struct Identity: Identifiable, Hashable {
   let id = UUID()
   var name: String
   
   var votes: [Vote]
}

struct Voting: Identifiable, Hashable {
   let id = UUID()
   var title: String
   var question: String
   var startet_at: Date
   var is_open: Bool
   
   var meeting: MeetingTest
   //var meetingID: UUID
   
   var voting_options: [Voting_option]
//   var votes: [Vote]
}

struct Vote: Identifiable, Hashable {
//   var id: String { "\(votingID.uuidString)-\(identityID.uuidString)" }
   var id = UUID()
   var voting: Voting
//   var identityID: UUID
   var index: UInt8
}

struct Voting_option: Identifiable, Hashable {
   var id = UUID()
//   var id: String { "\(votingID.uuidString)-\(index)" }
//
//   var voting: Voting
   var index: UInt8
   var text: String
   var count: Int?
}

struct MeetingTest: Identifiable, Hashable {
   let id = UUID()
   var title: String
   var start: Date
   var status: status
   
   //var votings: [Voting]
}

enum status: String, Codable {
   case scheduled
   case inSession
   case completed
}


struct VotingsView: View {
   
   @State private var getVotings: [GetVotingDTO] = []
   @State private var getVoting: GetVotingDTO?
   @State private var errorMessage: String?

   @State private var searchText = ""

   @State private var selectedVoting: GetVotingDTO?
   @State private var updatedResults: GetVotingResultsDTO?
   
   @State private var isShowingVoteSheet = false
   @State private var navigateToResultView = false
   @State private var navigateToNextView = false
   
   var votingsOfMeetings: [[GetVotingDTO]] {
      var votingsByMeeting: [UUID: [GetVotingDTO]] = [:]
      
      for voting in mockVotings {
         let meetingID = voting.meetingId
         if votingsByMeeting[meetingID] == nil {
            votingsByMeeting[meetingID] = []
         }
         votingsByMeeting[meetingID]?.append(voting)
      }
   
      var votingsOfMeetingsSorted: [[GetVotingDTO]] = Array(votingsByMeeting.values)
      
      votingsOfMeetingsSorted = votingsOfMeetingsSorted.map { $0.sorted { $0.startedAt! > $1.startedAt! } }

      votingsOfMeetingsSorted.sort {
              guard let firstVotingInGroup1 = $0.first, let firstVotingInGroup2 = $1.first else {
                  return false
              }
         return getMeeting(meetingID: firstVotingInGroup1.meetingId).start > getMeeting(meetingID: firstVotingInGroup2.meetingId).start
          }
      
      return votingsOfMeetingsSorted
   }
   
   var body: some View {
      ZStack {
         NavigationView {
//            if let error = errorMessage {
//               Text("\(error)")
//            } else {
//               List(getVotings, id: \.id) { voting in
//                  VStack(alignment: .leading) {
//                     Text(voting.question)
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                  }
//               }
//            }
//            
            
            if !votingsOfMeetings.isEmpty {
               List {
                  ForEach(votingsOfMeetings, id: \.self) { votingGroup in
                     Votings_VotingsSectionView(votingsView: VotingsView(), votingGroup: votingGroup, mockVotingResults: mockVotingResults, onVotingSelected: { voting in
                        selectedVoting = voting
                        if(mockVotingResults.myVote == nil && voting.isOpen) {
                           isShowingVoteSheet = true
                        } else {
                           navigateToResultView = true
                        }
                     })
                  }
               }
               .sheet(isPresented: $isShowingVoteSheet) {
                  if let voting = selectedVoting {
                     Votings_VoteView(voting: voting, votingResults: mockVotingResults, onNavigate: { results in
                        updatedResults = results
                        navigateToNextView = true
                     })
                     .navigationTitle(voting.question)
                  }
               }
               .navigationDestination(isPresented: $navigateToResultView) {
                  if let voting = selectedVoting {
                     Votings_VotingResultView(votingsView: VotingsView(), voting: voting, votingResults: mockVotingResults)
                        .navigationTitle(voting.question)
                  }
               }
               .navigationDestination(isPresented: $navigateToNextView) {
                  if let voting = selectedVoting, let results = updatedResults {
                     Votings_VotingResultView(votingsView: VotingsView(), voting: voting, votingResults: results)
                  }
               }
            } else {
               ContentUnavailableView {
                  Label("Keine Abstimmungen gefunden", systemImage: "document")
               }
            }
            
         }
         .navigationTitle("Abstimmungen")
         .navigationBarTitleDisplayMode(.large)
         .onAppear {
            loadVotings()
         }
      }
      .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Suchen")
      .onChange(of: searchText) {
         Task {
            if searchText == "" {
//               await getVotings
            } else {
               getVotings = getVotings.filter { voting in
                  return voting.question.starts(with: searchText)
               }
            }
         }
      }
      
   }
   
   func loadVotings() {
      APIService.shared.fetchAllVotings(token: "your_jwt_token") { result in
         DispatchQueue.main.async {
            switch result {
            case .success(let fetchedVotings):
               self.getVotings = fetchedVotings
            case .failure(let error):
               self.errorMessage = "Failed to load votings: \(error)"
            }
         }
      }
//      getVotings = mockVotings
   }
   
//   func loadVoting() {
//      APIService.shared.fetchVoting(votingId: UUID(uuidString: "example-id")!, token: "your_jwt_token") { result in
//         DispatchQueue.main.async {
//            switch result {
//            case .success(let fetchedVoting):
//               self.getVoting = fetchedVoting
//            case .failure(let error):
//               self.errorMessage = "Failed to fetch voting: \(error)"
//            }
//         }
//      }
//   }
   
   func getMeeting(meetingID: UUID) -> GetMeetingDTO {
      // API Call
      // loadMeetings()
      mockMeetings.first(where: { $0.id == meetingID }) ?? mockMeeting2
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
            anonymous: false,
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
            anonymous: false,
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
            anonymous: false,
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
            anonymous: false,
            options: mockOptions2
         ),
      ]
   }
   
   let mockOptions1: [GetVotingOptionDTO] = [
      GetVotingOptionDTO(votingId: UUID(), index: 0, text: "Enthaltung"),
      GetVotingOptionDTO(votingId: UUID(), index: 1, text: "Rot"),
      GetVotingOptionDTO(votingId: UUID(), index: 2, text: "Grün"),
      GetVotingOptionDTO(votingId: UUID(), index: 3, text: "Blau"),
   ]
   
   let mockOptions2: [GetVotingOptionDTO] = [
      GetVotingOptionDTO(votingId: UUID(), index: 0, text: "Enthaltung"),
      GetVotingOptionDTO(votingId: UUID(), index: 1, text: "Option1"),
      GetVotingOptionDTO(votingId: UUID(), index: 2, text: "Option2"),
      GetVotingOptionDTO(votingId: UUID(), index: 3, text: "Option3"),
      GetVotingOptionDTO(votingId: UUID(), index: 4, text: "Option4"),
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
         total: 2,
         percentage: 2,
         identities: []
      )
   }
   var mockVotingResult2: GetVotingResultDTO {
      return GetVotingResultDTO(
         index: 1, // Index 0: Abstention
         total: 8,
         percentage: 8,
         identities: []
      )
   }
   var mockVotingResult3: GetVotingResultDTO {
      return GetVotingResultDTO(
         index: 2, // Index 0: Abstention
         total: 10,
         percentage: 10,
         identities: []
      )
   }
   var mockVotingResult4: GetVotingResultDTO {
      return GetVotingResultDTO(
         index: 3, // Index 0: Abstention
         total: 30,
         percentage: 30,
         identities: []
      )
   }

   
   let mockIdentity: GetIdentityDTO = GetIdentityDTO(id: UUID(), name: "Max Mustermann")
   
}

#Preview {
   NavigationStack {
      VotingsView()
         .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
               Button {
               } label: {
                  HStack {
                     Image(systemName: "chevron.backward")
                     Text("Zurück")
                  }
               }
            }
         }
   }
}

