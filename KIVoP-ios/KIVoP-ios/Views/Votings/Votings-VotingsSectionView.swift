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
   @State private var voteCastedSymbolColor: Color = .black
   @State private var voteCastedStatus: String = ""

   @State private var isLoading = false
   @State private var error: String?
   
    var body: some View {
       Section(header: Text(meetingName)) {
          ForEach(votingGroup, id: \.self) { voting in
             HStack {
                Text(voting.question)
                   .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Image(systemName: "\(voteCastedStatus)")
                   .foregroundStyle(voteCastedSymbolColor)
                Spacer()
             }
             .contentShape(Rectangle())
             .onTapGesture {
                onVotingSelected(voting)
             }
             .onAppear {
                Task {
                   await setSymbolColorAndStatus(voting: voting)
                }
             }
          }
       }
       .onAppear {
          Task {
             await loadMeetingName(votingGroup: votingGroup)
          }
       }
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
         self.error = error.localizedDescription
      }
      isLoading = false
   }
   
   func setSymbolColorAndStatus(voting: GetVotingDTO) async {
      isLoading = true
      error = nil
      do {
         let results = try await APIService.shared.fetchVotingResults(by: voting.id)
         if (results.myVote != nil) {
            voteCastedSymbolColor = .blue
            voteCastedStatus = "checkmark"
         } else {
            voteCastedSymbolColor = voting.isOpen ? .orange : .black
            voteCastedStatus = voting.isOpen ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : ""
         }
      } catch {
         self.error = error.localizedDescription
      }
      isLoading = false
   }
   
   
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
