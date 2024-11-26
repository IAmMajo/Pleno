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
   
    var body: some View {
       Section(header: Text(getMeetingName(votingGroup: votingGroup))) {
          ForEach(votingGroup, id: \.self) { voting in
//             NavigationLink(destination: {
//                if (!sampleIdentity.votes.contains(where: { $0.voting.title == voting.title }) && voting.is_open) { //user has voted
//                   Votings_VoteView(voting: voting, sampleIdentity: sampleIdentity)
//                      .navigationTitle(voting.title)
//                } else {
//                   Votings_VotingResultView(voting: voting, sampleIdentity: sampleIdentity)
//                      .navigationTitle(voting.title)
//                }
//             }) {
//                HStack {
//                   Text(voting.title)
//                      .frame(maxWidth: .infinity, alignment: .leading)
//                   Spacer()
//                   Image(systemName: "\(voteCastedStatus(voting: voting))")
//                      .foregroundStyle(voteCastedSymbolColor(voting: voting))
//                   Spacer()
//                }
//             }
             
             HStack {
                Text(voting.question)
                   .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Image(systemName: "\(voteCastedStatus(voting: voting))")
                   .foregroundStyle(voteCastedSymbolColor(voting: voting))
                Spacer()
             }
             .contentShape(Rectangle())
             .onTapGesture {
                onVotingSelected(voting)
             }
          }
       }
    }
   
   func getMeetingName(votingGroup: [GetVotingDTO]) -> String {
//      var status: MeetingStatus = votingsView.getMeeting(meetingID: votingGroup.first!.meetingId).status
      let status = votingsView.getMeeting(meetingID: votingGroup.first!.meetingId).status
      if(status == MeetingStatus.inSession) {
         return "Aktuelle Sitzung"
      } else {
         return "\(votingsView.getMeeting(meetingID: votingGroup.first!.meetingId).name) - \(DateTimeFormatter.formatDate(votingsView.getMeeting(meetingID: votingGroup.first!.meetingId).start))"
      }
   }
   
   func getVotingResults(votingID: UUID) -> GetVotingResultsDTO {
      // API Call
      // loadVotingResults()
      return mockVotingResults
   }
   
   func voteCastedSymbolColor (voting: GetVotingDTO) -> Color {
      if (getVotingResults(votingID: voting.id).myVote != nil) {
         return .blue
      } else {
         return voting.isOpen ? .orange : .black
      }
   }
   
   func voteCastedStatus (voting: GetVotingDTO) -> String {
      if (getVotingResults(votingID: voting.id).myVote != nil) {
         return "checkmark"
      } else {
         return voting.isOpen ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : ""
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
