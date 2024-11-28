//
//  Votings-VotingsOverview.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 08.11.24.
//

import SwiftUI
import MeetingServiceDTOs


struct VotingsView: View {
   
   @State private var meetings: [GetMeetingDTO] = []
   @State private var votings: [GetVotingDTO] = []
   @State private var votingResults: GetVotingResultsDTO?
   @State private var votingsFiltered: [GetVotingDTO] = []
   @State private var voting: GetVotingDTO?
   @State private var votingsOfMeetings: [[GetVotingDTO]] = []
   
   @State private var isLoading = false
   @State private var error: String?

   @State private var searchText = ""

   @State private var selectedVoting: GetVotingDTO?
   @State private var updatedResults: GetVotingResultsDTO?
   @State private var hasVoted: Bool = false
   @State private var selectedOption: UInt8?
   
   @State private var isShowingVoteSheet = false
   @State private var navigateToResultView = false
   @State private var navigateToNextView = false
 
   func setVotingsOfMeetings() async {
       var votingsByMeeting: [UUID: [GetVotingDTO]] = [:]
       
       for voting in votingsFiltered {
           let meetingID = voting.meetingId
           if votingsByMeeting[meetingID] == nil {
               votingsByMeeting[meetingID] = []
           }
           votingsByMeeting[meetingID]?.append(voting)
       }

       var votingsOfMeetingsSorted: [[GetVotingDTO]] = Array(votingsByMeeting.values)
       
       votingsOfMeetingsSorted = votingsOfMeetingsSorted.map {
          $0.sorted { ($0.startedAt ?? Date.now) > ($1.startedAt ?? Date.now) }
       }
       
       // Fetch meeting data for sorting
       var meetingStartDates: [UUID: Date] = [:]
       for group in votingsOfMeetingsSorted {
           if let firstVoting = group.first {
              isLoading = true
              error = nil
              do {
                 let meeting = try await APIService.shared.fetchMeeting(by: firstVoting.meetingId)
                 meetingStartDates[firstVoting.meetingId] = meeting.start
              } catch {
                  self.error = error.localizedDescription
              }
              isLoading = false
           }
       }

       // Sort groups based on meeting start dates
       votingsOfMeetingsSorted.sort {
           guard let meeting1Start = meetingStartDates[$0.first?.meetingId ?? UUID()],
                 let meeting2Start = meetingStartDates[$1.first?.meetingId ?? UUID()] else {
               return false
           }
           return meeting1Start > meeting2Start
       }
       
       self.votingsOfMeetings = votingsOfMeetingsSorted
   }
   
   var body: some View {
      ZStack {
         NavigationView {
            if !votingsOfMeetings.isEmpty {
               List {
                  ForEach(votingsOfMeetings, id: \.self) { votingGroup in
                     Votings_VotingsSectionView(votingsView: VotingsView(), votingGroup: votingGroup, mockVotingResults: mockVotingResults, onVotingSelected: { voting in
                        selectedVoting = voting
                        Task {
                           if (selectedVoting != nil) {
                              hasVoted = VotingStateTracker.hasVoted(for: voting.id)
                              await loadVotingResults(voting: voting)
                           }
                           if(votingResults?.myVote == nil && voting.isOpen && !hasVoted) {
                              isShowingVoteSheet = true
                           } else {
                              navigateToResultView = true
                           }
                        }
                     })
                  }
               }
               .refreshable {
                  await loadVotings()
                  votingsFiltered = votings
                  await setVotingsOfMeetings()
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
                        .navigationTitle("Abstimmungs-Ergebnis")
                  }
               }
               .navigationDestination(isPresented: $navigateToNextView) {
                  if let voting = selectedVoting, let results = updatedResults {
                     Votings_VotingResultView(votingsView: VotingsView(), voting: voting, votingResults: results)
                  }
               }
            } else {
               ContentUnavailableView {
//                  Label("Keine Abstimmungen gefunden", systemImage: "document")
               }
            }
            
         }
         .navigationTitle("Abstimmungen")
         .navigationBarTitleDisplayMode(.large)
//         .task(id: selectedVoting) {
//            if let voting = selectedVoting {
//               hasVoted = VotingStateTracker.hasVoted(for: voting.id)
//               await loadVotingResults(voting: voting)
//            }
//         }
         .onAppear {
            Task {
               try await AuthController.shared.login(email: "admin@kivop.ipv64.net", password: "admin")
               let token = try await AuthController.shared.getAuthToken()
               print("Token: \(token)")

               await loadVotings()
//               votings = mockVotings
               votingsFiltered = votings
               await setVotingsOfMeetings()
            }
         }
         .overlay {
            if isLoading {
               ProgressView("Loading...")
            } else if let error = error {
               Text("Error: \(error)")
                  .foregroundColor(.red)
            }
         }
         
      }
      .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Suchen")
      .onChange(of: searchText) {
         Task {
            if searchText.isEmpty {
               votingsFiltered = votings
            } else {
               votingsFiltered = votings.filter { voting in
                  return voting.question.contains(searchText)
               }
            }
         }
      }
      
   }
   

   private func loadVotings() async {
      isLoading = true
      error = nil
      do {
         votings = try await APIService.shared.fetchAllVotings()
      } catch {
         print("error: ", error)
      }
      isLoading = false
   }
   
   private func loadVotingResults(voting: GetVotingDTO) async {
      isLoading = true
      error = nil
      do {
         votingResults = try await APIService.shared.fetchVotingResults(by: voting.id)
      } catch {
         print("error: ", error)
      }
      isLoading = false
   }
   
   private func loadMeetings() async {
      isLoading = true
      error = nil
      do {
         meetings = try await APIService.shared.fetchAllMeetings()
      } catch {
         print("error: ", error)
      }
      isLoading = false
   }
   
   
   
//   func getMeeting(meetingId: UUID) -> GetMeetingDTO {
//      // API Call
//      // loadMeetings()
//      mockMeetings.first(where: { $0.id == meetingID }) ?? mockMeeting2
//   }
   
   
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

