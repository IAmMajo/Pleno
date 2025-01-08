//
//  Votings-VotingsOverview.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 08.11.24.
//

import SwiftUI
import MeetingServiceDTOs


struct VotingsView: View {
   @StateObject private var webSocketService = WebSocketService()
   @StateObject private var votingService = VotingService.shared
   @StateObject private var meetingViewModel = MeetingViewModel()
   
   @State private var meetings: [GetMeetingDTO] = []
   var votings: [GetVotingDTO] {
//      let votings = votingService.votings
//      var openVotings: [GetVotingDTO] = []
//      for voting in votings {
//         if (voting.isOpen) {
//            openVotings.append(voting)
//         }
//      }
//      return openVotings
      
//      votingsOfMeetings = allVotings.filter { $0.isOpen }
      
      return votingService.votings
   }
   @State private var votingResults: GetVotingResultsDTO?
   @State private var votingsFiltered: [GetVotingDTO] = []
   @State private var voting: GetVotingDTO?
   @State private var votingsOfMeetings: [[GetVotingDTO]] = []
   
   @State private var isLoading = false
   @State private var error: String?

   @State private var searchText = ""

   @State private var selectedVoting: GetVotingDTO?
   @State private var updatedResults: GetVotingResultsDTO?
//   @State private var hasVoted: Bool = false
   @State private var selectedOption: UInt8?
   
   @State private var isShowingVoteSheet = false
   @State private var navigateToResultView = false
   @State private var navigateToNextView = false
   
   @State private var alertMessage: AlertMessage?

   struct AlertMessage: Identifiable {
       let id = UUID()
       let message: String
   }
 
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
              do {
                 let meeting = try await meetingViewModel.fetchMeeting(byId: firstVoting.meetingId)
                 meetingStartDates[firstVoting.meetingId] = meeting.start
              } catch {
                 print("Error fetching meeting: \(error.localizedDescription)")
              }
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
//         print("setVotingsOfMeetings sorted")
      self.votingsOfMeetings = votingsOfMeetingsSorted
//      print("setVotingsOfMeetings updated: \(self.votingsOfMeetings.flatMap { $0.map { $0.isOpen } })")
   }
   
   private func hasVotedForOpenVoting(votingId: UUID) async -> Bool {
      await withCheckedContinuation { continuation in
         webSocketService.connect(to: votingId)
         
         // Wait for the WebSocket to receive messages
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            print("liveStatus: \(webSocketService.liveStatus ?? "")")
//            print("votingResults: \(String(describing: webSocketService.votingResults))")
//            print("errorMessage: \(webSocketService.errorMessage ?? "")")
            if let liveStatus = webSocketService.liveStatus, !liveStatus.isEmpty {
               webSocketService.disconnect()
               continuation.resume(returning: true)
            } else if webSocketService.votingResults != nil {
               webSocketService.disconnect()
               continuation.resume(returning: false)
            } else if webSocketService.errorMessage != nil {
               webSocketService.disconnect()
               continuation.resume(returning: false)
            } else {
               webSocketService.disconnect()
               continuation.resume(returning: false)
            }
         }
      }
   }
   
   var body: some View {
      ZStack {
         ZStack {
            if isLoading {
                        ProgressView("Loading...")
                    } else if votingsOfMeetings.isEmpty {
                        ContentUnavailableView {
                            Label("Keine Abstimmungen gefunden", systemImage: "document")
                        }
                    } else {
               List {
                  ForEach(votingsOfMeetings, id: \.self) { votingGroup in
                     Votings_VotingsSectionView(
                        votingsView: self,
                        votingGroup: votingGroup,
                        mockVotingResults: mockVotingResults,
                        onVotingSelected: { voting in
                           selectedVoting = voting
                           Task {
                              await loadVotings()
                              // Find the updated voting in the refreshed votings
                              if let updatedVoting = votingService.votings.first(where: { $0.id == voting.id }) {
                                 selectedVoting = updatedVoting
                                 
                                 let hasVotedForOpenVoting = await hasVotedForOpenVoting(votingId: updatedVoting.id)
                                 
                                 print("Selected Voting isOpen: \(selectedVoting?.isOpen ?? false)")
                                 print(updatedVoting.isOpen)
                                 print(!hasVotedForOpenVoting)
                                 
                                 if(updatedVoting.isOpen && !hasVotedForOpenVoting) {
                                    isShowingVoteSheet = true
                                 } else {
                                    navigateToResultView = true
                                 }
                              }
                           }
                     })
                  }
               }
               .id(UUID()) // Force list refresh
               .refreshable {
                  await loadVotings()
                  votingsFiltered = votingService.votings
                  await setVotingsOfMeetings()
                  print("refreshed")
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
//                        .navigationTitle("Abstimmungs-Ergebnis")
                  }
               }
               .navigationDestination(isPresented: $navigateToNextView) {
                  if let voting = selectedVoting, let results = updatedResults {
                     Votings_VotingResultView(votingsView: VotingsView(), voting: voting, votingResults: results)
                  }
               }
            }
         }
         .navigationTitle("Abstimmungen")
         .navigationBarTitleDisplayMode(.large)
         .onAppear {
            Task {
               isLoading = true
               await loadVotings()
//               votings = mockVotings
               votingsFiltered = votings
               await setVotingsOfMeetings()
               isLoading = false
            }
         }
         .onChange(of: votingService.votings) { old, new in
            Task {
//               votingsFiltered = votingService.votings
               // Refilter votings based on the updated data
//               votingsFiltered = votingService.votings.filter { $0.isOpen }
               votingsFiltered = new
//               votingsFiltered = votingService.votings
               await setVotingsOfMeetings()
               print("votingsFiltered: \(votingsFiltered.map { ($0.id, $0.isOpen) })")
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
      .onChange(of: searchText) { old, newValue in
         votingsFiltered = votingService.votings.filter { voting in
            newValue.isEmpty || voting.question.localizedCaseInsensitiveContains(newValue)
         }
         Task {
            await setVotingsOfMeetings()
         }
      }
      
   }
   
   private func loadVotings() async {
      do {
         let votings = try await votingService.fetchVotings()
         votingService.votings = votings
         votingsFiltered = votings
         await setVotingsOfMeetings()
         print("loadVotings: \(votingService.votings.map { ($0.id, $0.isOpen) })")
         print("Loaded \(votings.count) votings")
      } catch {
         // Handle error
         alertMessage = AlertMessage(message: "Fehler beim Laden der Abstimmungen: \(error.localizedDescription)")
         print("Error loading votings: \(error.localizedDescription)")
      }
   }
   
   private func loadVotingResults(voting: GetVotingDTO) async {
      VotingService.shared.fetchVotingResults(votingId: voting.id) { result in
           DispatchQueue.main.async {
               switch result {
               case .success(let results):
                   self.votingResults = results
               case .failure(_ /*let error*/): break
//                   print("Fehler beim Abrufen der Ergebnisse: \(error.localizedDescription)")
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

