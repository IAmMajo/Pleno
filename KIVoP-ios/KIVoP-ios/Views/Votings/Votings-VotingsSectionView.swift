//
//  Votings-VotingsSectionView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 17.11.24.
//

import SwiftUI
import MeetingServiceDTOs

struct Votings_VotingsSectionView: View {
   var votingsView: VotingsView
   
   let votingGroup: [GetVotingDTO]
   let mockVotingResults: GetVotingResultsDTO
   var onVotingSelected: (GetVotingDTO) -> Void
   
   @State private var meetingName: String = ""
   @State private var votingViewModels: [VotingViewModel] = []
   @State private var isVotingFinished: Bool = false


   @State private var isLoading = false
   @State private var error: String?
   
    var body: some View {
       Section(header: Text(meetingName)) {
          ForEach(votingViewModels) { viewModel in
             if (viewModel.voting.startedAt == nil) {
             } else {
//                HStack {
//                   Text(viewModel.voting.question)
//                      .frame(maxWidth: .infinity, alignment: .leading)
//                   Spacer()
//                   Image(systemName: "\(viewModel.status)")
//                      .foregroundStyle(viewModel.symbolColor)
//                   Spacer()
//                }
//                .contentShape(Rectangle())
//                .onTapGesture {
//                   onVotingSelected(viewModel.voting)
//                }
//                .task {
//                   await viewModel.loadSymbolColorAndStatus()
//                }
                Votings_VotingRowView(viewModel: viewModel, onVotingSelected: onVotingSelected)
             }
          }
       }
       .onAppear {
          Task {
             await initializeViewModelsAndMeetingName()
          }
       }
    }
   
   private func initializeViewModelsAndMeetingName() async {
          votingViewModels = votingGroup.map { VotingViewModel(voting: $0) }
          await loadMeetingName(votingGroup: votingGroup)
      }
   
   private func loadMeetingName(votingGroup: [GetVotingDTO]) async {
      isLoading = true
      error = nil
      do {
         let meeting = try await APIService.shared.fetchMeeting(by: votingGroup.first!.meetingId)
         
         let status = meeting.status
         if(status == MeetingStatus.inSession) {
            meetingName = "Aktuelle Sitzung"
         } else {
            meetingName = "\(meeting.name) - \(DateTimeFormatter.formatDate(meeting.start))"
         }
      } catch {
         print("error: ", error)
      }
      isLoading = false
   }
   
//   func setSymbolColorAndStatus(voting: GetVotingDTO) async {
//      isLoading = true
//      error = nil
//      do {
//         let results = try await APIService.shared.fetchVotingResults(by: voting.id)
////         let results = mockVotingResults
//         if (results.myVote != nil) {
//            voteCastedSymbolColor = .blue
//            voteCastedStatus = "checkmark"
//         } else {
//            voteCastedSymbolColor = voting.isOpen ? .orange : .black
//            voteCastedStatus = voting.isOpen ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : ""
//         }
//      } catch {
//         print("error: ", error)
//         voteCastedSymbolColor = voting.isOpen ? .orange : .black
//         print("voteCastedSymbolColor: \(voteCastedSymbolColor)")
//         voteCastedStatus = voting.isOpen ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : ""
//         print("voteCastStatus: \(voteCastedStatus)")
//      }
//      isLoading = false
//   }
   
   
   //   func getMeetingName(votingGroup: [GetVotingDTO]) -> String {
   //      let status = votingsView.getMeeting(meetingID: votingGroup.first!.meetingId).status
   //      if(status == MeetingStatus.inSession) {
   //         return "Aktuelle Sitzung"
   //      } else {
   //         return "\(votingsView.getMeeting(meetingID: votingGroup.first!.meetingId).name) - \(DateTimeFormatter.formatDate(votingsView.getMeeting(meetingID: votingGroup.first!.meetingId).start))"
   //      }
   //   }
   
//   func getVotingResults(votingID: UUID) -> GetVotingResultsDTO {
//      return mockVotingResults
//   }
//   
//   func voteCastedSymbolColor (voting: GetVotingDTO) -> Color {
//      if (getVotingResults(votingID: voting.id).myVote != nil) {
//         return .blue
//      } else {
//         return voting.isOpen ? .orange : .black
//      }
//   }
//   
//   func voteCastedStatus (voting: GetVotingDTO) -> String {
//      if (getVotingResults(votingID: voting.id).myVote != nil) {
//         return "checkmark"
//      } else {
//         return voting.isOpen ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : ""
//      }
//   }
}

#Preview {
   var votingsView: VotingsView = .init()
   var mockVotings = votingsView.mockVotings
   var mockVotingResults = votingsView.mockVotingResults
   
   Votings_VotingsSectionView(votingsView: votingsView, votingGroup: mockVotings, mockVotingResults: mockVotingResults, onVotingSelected: { voting in
   })
}
