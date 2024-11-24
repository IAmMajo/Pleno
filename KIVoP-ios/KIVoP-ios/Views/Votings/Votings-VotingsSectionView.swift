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
   let mockIdentity: GetIdentityDTO
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
//                Image(systemName: "\(voteCastedStatus(voting: voting))")
//                   .foregroundStyle(voteCastedSymbolColor(voting: voting))
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
      if(votingsView.getMeeting(meetingID: votingGroup.first!.meetingId).status == MeetingStatus.inSession) {
         return "Aktuelle Sitzung"
      } else {
         return "\(votingsView.getMeeting(meetingID: votingGroup.first!.meetingId).name) - \(DateTimeFormatter.formatDate(votingsView.getMeeting(meetingID: votingGroup.first!.meetingId).start))"
      }
   }
   
//   func voteCastedSymbolColor (voting: GetVotingDTO) -> Color {
//      if (sampleIdentity.votes.contains(where: { $0.voting.title == voting.title })) { // später mit id
//         return .blue
//      } else {
//         return voting.is_open ? .orange : .black
//      }
//   }
//   
//   func voteCastedStatus (voting: GetVotingDTO) -> String {
//      if (sampleIdentity.votes.contains(where: { $0.voting.title == voting.title })) { // später mit id
//         return "checkmark"
//      } else {
//         return voting.is_open ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : ""
//      }
//   }
}

#Preview {
   var votingsView: VotingsView = .init()
   var mockVotings = votingsView.mockVotings
   var mockIdentity = votingsView.mockIdentity
   
   Votings_VotingsSectionView(votingsView: votingsView, votingGroup: mockVotings, mockIdentity: mockIdentity, onVotingSelected: { voting in
   })
}
