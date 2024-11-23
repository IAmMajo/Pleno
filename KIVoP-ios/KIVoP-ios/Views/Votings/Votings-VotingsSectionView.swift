//
//  Votings-VotingsSectionView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 17.11.24.
//

import SwiftUI

struct Votings_VotingsSectionView: View {
   
   let votingGroup: [Voting]
   let sampleIdentity: Identity
   var onVotingSelected: (Voting) -> Void
   
    var body: some View {
       Section(header: Text(getMeetingTitle(votingGroup: votingGroup))) {
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
                Text(voting.title)
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
   
   func getMeetingTitle(votingGroup: [Voting]) -> String {
      if (votingGroup.first?.meeting.status == .inSession) {
         return "Aktuelle Sitzung"
      } else {
         return "\(votingGroup.first?.meeting.title ?? "") - \(DateTimeFormatter.formatDate(votingGroup.first?.meeting.start ?? Date()))"
      }
   }
   
   func voteCastedSymbolColor (voting: Voting) -> Color {
      if (sampleIdentity.votes.contains(where: { $0.voting.title == voting.title })) { // später mit id
         return .blue
      } else {
         return voting.is_open ? .orange : .black
      }
   }
   
   func voteCastedStatus (voting: Voting) -> String {
      if (sampleIdentity.votes.contains(where: { $0.voting.title == voting.title })) { // später mit id
         return "checkmark"
      } else {
         return voting.is_open ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : ""
      }
   }
}

#Preview {
   Votings_VotingsSectionView(votingGroup: [Voting(title: "Vereinsfarbe", question: "Welche Farbe soll die neue Vereinsfarbe werden?", startet_at: Date.now, is_open: true, meeting: MeetingTest(title: "Jahreshauptversammlung", start: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, status: .inSession), voting_options: [
      Voting_option(index: 0, text: "Enthaltung"),
      Voting_option(index: 1, text: "Rot"),
      Voting_option(index: 2, text: "Grün"),
      Voting_option(index: 3, text: "Blau"),
   ])], sampleIdentity: Identity(name: "Max Mustermann", votes: [Vote(voting: Voting(title: "Abstimmung2", question: "Welche Option soll gewählt werden 2?", startet_at: Calendar.current.date(byAdding: .minute, value: -15, to: Date())!, is_open: false, meeting: MeetingTest(title: "Jahreshauptversammlung", start: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, status: .inSession), voting_options: [
      Voting_option(index: 0, text: "Enthaltung", count: 4),
      Voting_option(index: 1, text: "Option1", count: 10),
      Voting_option(index: 2, text: "Option2", count: 15),
      Voting_option(index: 3, text: "Option3", count: 5),
      Voting_option(index: 4, text: "Option4", count: 30),
   ]), index: 2), Vote(voting: Voting(title: "Abstimmung5", question: "Welche Option soll gewählt werden 5?", startet_at: Date.distantPast, is_open: false, meeting: MeetingTest(title: "Sitzung2", start: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, status: .completed), voting_options: [
      Voting_option(index: 0, text: "Enthaltung", count: 4),
      Voting_option(index: 1, text: "Option1", count: 10),
      Voting_option(index: 2, text: "Option2", count: 15),
      Voting_option(index: 3, text: "Option3", count: 5),
      Voting_option(index: 4, text: "Option4", count: 30),
   ]), index: 0)]), onVotingSelected: { voting in
   })
}
