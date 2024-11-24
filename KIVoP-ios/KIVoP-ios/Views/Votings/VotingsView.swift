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
   
   var _dateComponents1: DateComponents {
      var dateComponents1 = DateComponents()
      dateComponents1.day = -7
      dateComponents1.minute = -15
      return dateComponents1
   }
   
   var _dateComponents2: DateComponents {
      var dateComponents2 = DateComponents()
      dateComponents2.day = -7
      dateComponents2.minute = -15
      return dateComponents2
   }
   
   var votingGroup: [Voting] {
      return [Voting(title: "Vereinsfarbe", question: "Welche Farbe soll die neue Vereinsfarbe werden?", startet_at: Date.now, is_open: true, meeting: sampleMeetings[0], voting_options: options1),]
   }

   
   ///////////////////////////////////////////////////////////////////////
   
//   let getVoting: GetVotingDTO
//   @StateObject private var votingsViewModel = VotingsViewModel()
   @State private var getVotings: [GetVotingDTO] = []
   @State private var getVoting: GetVotingDTO?
   @State private var errorMessage: String?

   @State private var searchText = ""

   @State private var selectedVoting: Voting?
   @State private var updatedIdentity: Identity?
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
//            if !votingsOfMeetings.isEmpty {
//               List {
//                  ForEach(votingsOfMeetings, id: \.self) { votingGroup in
//                     Votings_VotingsSectionView(votingGroup: votingGroup, sampleIdentity: sampleIdentity, onVotingSelected: { voting in
//                        selectedVoting = voting
//                        if (!sampleIdentity.votes.contains(where: { $0.voting.title == voting.title }) && voting.is_open) {
//                           isShowingVoteSheet = true
//                        } else {
//                           navigateToResultView = true
//                        }
//                     })
//                  }
//               }
//               .sheet(isPresented: $isShowingVoteSheet) {
//                  if let voting = selectedVoting {
//                     Votings_VoteView(voting: voting, sampleIdentity: sampleIdentity, onNavigate: { identity in
//                        updatedIdentity = identity
//                        navigateToNextView = true
//                     })
//                        .navigationTitle(voting.title)
//                  }
//               }
//               .navigationDestination(isPresented: $navigateToResultView) {
//                  if let voting = selectedVoting {
//                     Votings_VotingResultView(voting: voting, sampleIdentity: sampleIdentity)
//                        .navigationTitle(voting.title)
//                  }
//               }
//               .navigationDestination(isPresented: $navigateToNextView) {
//                  if let voting = selectedVoting, let identity = updatedIdentity {
//                     Votings_VotingResultView(voting: voting, sampleIdentity: identity)
//                  }
//               }
//            } else {
//               ContentUnavailableView {
//                  Label("Keine Abstimmungen gefunden", systemImage: "document")
//               }
//            }
            
            
//            if votingsViewModel.isLoading {
//               ProgressView("Loading votings...")
//            } else if let error = votingsViewModel.errorMessage {
//               Text("Error: \(error)")
//                  .foregroundColor(.red)
//            } else {
//               List(votingsViewModel.votings) { voting in
//                  VStack(alignment: .leading) {
//                     Text(voting.question)
//                        .font(.headline)
//                     Text("Meeting ID: \(voting.meetingId.uuidString)")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                  }
//               }
//            }
            
            
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
            
            
            if !votingsOfMeetings.isEmpty {
               List {
                  ForEach(votingsOfMeetings, id: \.self) { votingGroup in
//                     Votings_VotingsSectionView(votingsView: VotingsView(), votingGroup: votingGroup, mockIdentity: mockIdentity, onVotingSelected: { voting in
//                        selectedVoting = voting
//                        if (!sampleIdentity.votes.contains(where: { $0.voting.title == voting.title }) && voting.is_open) {
//                           isShowingVoteSheet = true
//                        } else {
//                           navigateToResultView = true
//                        }
//                     })
                  }
               }
               .sheet(isPresented: $isShowingVoteSheet) {
                  if let voting = selectedVoting {
                     Votings_VoteView(voting: voting, sampleIdentity: sampleIdentity, onNavigate: { identity in
                        updatedIdentity = identity
                        navigateToNextView = true
                     })
                     .navigationTitle(voting.title)
                  }
               }
               .navigationDestination(isPresented: $navigateToResultView) {
                  if let voting = selectedVoting {
                     Votings_VotingResultView(voting: voting, sampleIdentity: sampleIdentity)
                        .navigationTitle(voting.title)
                  }
               }
               .navigationDestination(isPresented: $navigateToNextView) {
                  if let voting = selectedVoting, let identity = updatedIdentity {
                     Votings_VotingResultView(voting: voting, sampleIdentity: identity)
                  }
               }
            } else {
               ContentUnavailableView {
                  Label("Keine Abstimmungen gefunden", systemImage: "document")
               }
            }
            
            
//            if votingsViewModel.isLoading {
//               ProgressView("Loading votings...")
//            } else if let error = votingsViewModel.errorMessage {
//               Text("Error: \(error)")
//                  .foregroundColor(.red)
//            } else {
//               List(votingsViewModel.votings) { voting in
//                  VStack(alignment: .leading) {
//                     Text(voting.question)
//                        .font(.headline)
//                     Text("Meeting ID: \(voting.meetingId.uuidString)")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                  }
//               }
//            }
            
         }
         .navigationTitle("Abstimmungen")
         .navigationBarTitleDisplayMode(.large)
         .onAppear {
//            votingsViewModel.fetchVotings()
            loadVotings()
         }
      }
      .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Suchen")
      //      .onChange(of: $searchText) {}
      //.onChange(of: $searchText) {
      //    Task {
      //        if searchText == "" {
      //           await sampleVotings
      //        }
      //
      //        sampleVotings = sampleVotings.filter { voting in
      //            return voting.title.starts(with: searchText)
      //        }
      //    }
      // }
      
   }
   
   func loadVotings() {
//      APIService.shared.fetchAllVotings(token: "your_jwt_token") { result in
//         DispatchQueue.main.async {
//            switch result {
//            case .success(let fetchedVotings):
//               self.getVotings = fetchedVotings
//            case .failure(let error):
//               self.errorMessage = "Failed to load votings: \(error)"
//            }
//         }
//      }
      getVotings = mockVotings
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
      mockMeetings.first(where: { $0.id == meetingID }) ?? mockMeeting1
   }
   
   
   var mockVotings: [GetVotingDTO] {
      return [
         GetVotingDTO(
            id: UUID(),
            meetingId: mockMeeting1.id,
            question: "Welche Farbe soll die neue Vereinsfarbe werden?",
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
         results: [mockVotingResult1, mockVotingResult2, mockVotingResult3, mockVotingResult4, mockVotingResult5]
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
   var mockVotingResult5: GetVotingResultDTO {
      return GetVotingResultDTO(
         index: 4, // Index 0: Abstention
         total: 50,
         percentage: 50,
         identities: [mockIdentity]
      )
   }
   
   let mockIdentity: GetIdentityDTO = GetIdentityDTO(id: UUID(), name: "Max Mustermann")
   
   
   
   var sampleIdentity: Identity {
      return Identity(name: "Max Mustermann", votes: [Vote(voting: sampleVotings[4], index: 2), Vote(voting: sampleVotings[2], index: 0)])
   }
   
   let sampleMeetings = [
      MeetingTest(title: "Jahreshauptversammlung", start: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, status: .inSession),
      MeetingTest(title: "Sitzung2", start: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, status: .completed)
   ]
   
   var sampleVotings: [Voting] {
      return [
         Voting(title: "Vereinsfarbe", question: "Welche Farbe soll die neue Vereinsfarbe werden?", startet_at: Date.now, is_open: true, meeting: sampleMeetings[0], voting_options: options1),
         Voting(title: "Abstimmung5", question: "Welche Option soll gewählt werden 5?", startet_at: Calendar.current.date(byAdding: _dateComponents1, to: Date())!, is_open: false, meeting: sampleMeetings[1], voting_options: options2),
         Voting(title: "Abstimmung3", question: "Welche Option soll gewählt werden 3?", startet_at: Calendar.current.date(byAdding: .minute, value: -35, to: Date())!, is_open: false, meeting: sampleMeetings[0], voting_options: options2),
         Voting(title: "Abstimmung4", question: "Welche Option soll gewählt werden 4?", startet_at: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, is_open: false, meeting: sampleMeetings[1], voting_options: options2),
         Voting(title: "Abstimmung2", question: "Welche Option soll gewählt werden 2?", startet_at: Calendar.current.date(byAdding: .minute, value: -15, to: Date())!, is_open: false, meeting: sampleMeetings[0], voting_options: options2),
         Voting(title: "Abstimmung6", question: "Welche Option soll gewählt werden 6?", startet_at: Calendar.current.date(byAdding: _dateComponents2, to: Date())!, is_open: false, meeting: sampleMeetings[1], voting_options: options2)
         ]
   }
   
   var options1: [Voting_option] = [
        Voting_option(index: 0, text: "Enthaltung", count: 10),
        Voting_option(index: 1, text: "Rot", count: 10),
        Voting_option(index: 2, text: "Grün", count: 30),
        Voting_option(index: 3, text: "Blau", count: 50),
   ]
   
   
   var options2: [Voting_option] = [
      Voting_option(index: 0, text: "Enthaltung", count: 4),
      Voting_option(index: 1, text: "Option1", count: 10),
      Voting_option(index: 2, text: "Option2", count: 15),
      Voting_option(index: 3, text: "Option3", count: 30),
      Voting_option(index: 4, text: "Option4", count: 8),
   ]
   
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

