//
//  Votings-VotingsSectionView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 17.11.24.
//

import SwiftUI
import MeetingServiceDTOs

struct Votings_VotingsSectionView: View {
   @StateObject private var votingService = VotingService.shared
   @StateObject private var meetingViewModel = MeetingViewModel()
   
   var votingsView: VotingsView
   
   @State var votingGroup: [GetVotingDTO]
   let mockVotingResults: GetVotingResultsDTO
   var onVotingSelected: (GetVotingDTO) -> Void
   
   @State private var meetingName: String = ""
   @State private var votingViewModels: [VotingViewModel] = []
   @State private var isVotingFinished: Bool = false


   @State private var isLoading = false
   @State private var error: String?
   
    var body: some View {
       Section(header: Text(meetingName)) {
          ForEach(votingViewModels, id: \.id) { viewModel in
             if (viewModel.voting.startedAt == nil) {
             } else {
                Votings_VotingRowView(viewModel: viewModel, onVotingSelected: onVotingSelected)
             }
          }
       }
       .onAppear {
          Task {
             await initializeViewModelsAndMeetingName()
          }
       }
       .onChange(of: votingGroup) { old, newValue in
          Task {
             print("SectionView: votingGroup changed")
             await initializeViewModelsAndMeetingName()
          }
       }
    }
   
   private func initializeViewModelsAndMeetingName() async {
//          votingViewModels = votingGroup.map { VotingViewModel(voting: $0) }
//          await loadMeetingName(votingGroup: votingGroup)
      if votingViewModels.isEmpty || votingViewModels.count != votingGroup.count {
         votingViewModels = votingGroup.map { VotingViewModel(voting: $0) }
//         print("initializeViewModelsAndMeetingName votingViewModels reinitialized")
      }
      await loadMeetingName(votingGroup: votingGroup)
//      print("initializeViewModelsAndMeetingName executed")
   }
   
   private func loadMeetingName(votingGroup: [GetVotingDTO]) async {
      do {
         let meeting = try await meetingViewModel.fetchMeeting(byId: votingGroup.first!.meetingId)
         let status = meeting.status
         if(status == MeetingStatus.inSession) {
            meetingName = "Aktuelle Sitzung"
         } else {
            meetingName = "\(meeting.name) - \(DateTimeFormatter.formatDate(meeting.start))"
         }
      } catch {
         print("Error fetching meeting: \(error.localizedDescription)")
      }
   }
}

#Preview {
   var votingsView: VotingsView = .init()
   var mockVotings = votingsView.mockVotings
   var mockVotingResults = votingsView.mockVotingResults
   
   Votings_VotingsSectionView(votingsView: votingsView, votingGroup: mockVotings, mockVotingResults: mockVotingResults, onVotingSelected: { voting in
   })
}
