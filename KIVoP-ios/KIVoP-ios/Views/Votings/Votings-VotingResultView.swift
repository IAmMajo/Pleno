//
//  Votings-VotingResultView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 15.11.24.
//

import SwiftUI
import LocalAuthentication

struct Votings_VotingResultView: View {
   
//   @Binding var path: [String]
//   @Binding var shouldPopToVotingsView: Bool
   
   let voting: Voting
//   let colorMapping: [UInt8: Color]
   var sampleIdentity: Identity
   
//   @State private var navigateToNextView = false
   
   func getColor (index: UInt8) -> Color {
      return colorMapping[index] ?? .gray
   }
   
   func selection (voting: Voting) -> Voting_option? {
//      return voting.voting_options[3]
      if (sampleIdentity.votes.contains(where: { $0.voting.title == voting.title })) {
         let index = sampleIdentity.votes.first(where: {$0.voting.title == voting.title})?.index
         return voting.voting_options.first(where: {$0.index == index})
      }
     return nil
   }

   var votesCount: Int {
      return voting.voting_options.reduce(0, { x, y in
         x + (y.count ?? 0)})
   }
   
   func getPercent (option: Voting_option) -> Int {
      guard votesCount > 0 else {
         return 0 // Return 0% if there are no votes
      }
      return Int((Float(option.count ?? 0) / Float(votesCount)) * 100)
   }
   
    var body: some View {
       Group {
          VStack {
             Divider()
             
             PieChartView(options: voting.voting_options)
             .padding()
             
             Divider()
             
             HStack {
                Image(systemName: "person.bust.fill")
                Text(voting.meeting.title)
                   .frame(maxWidth: .infinity, alignment: .leading)
             }
             .padding(.leading)
             Text(voting.question)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading).padding(.top, 5).padding(.trailing)
                .font(.title2)
                .fontWeight(.medium)
            
             List{
                Section {
                   ForEach (voting.voting_options, id: \.self) { option in
                      HStack {
                         Image(systemName: selection(voting: voting) == option ? "checkmark.circle.fill" : "circle.fill")
                            .foregroundStyle(getColor(index: option.index))
//                            .foregroundStyle(.gray)
                         Text(option.text)
                         Spacer()
                         Text("\(getPercent(option: option))%")
                            .opacity(0.6)
                      }
//                      .listRowBackground(colorMapping[option.index].opacity(0.4))
                   }
                } header: {
                   Spacer(minLength: 0).listRowInsets(EdgeInsets())
                }
             }
//             .scrollContentBackground(.hidden)
             .environment(\.defaultMinListHeaderHeight, 10)
          }
       }
       .navigationBarTitleDisplayMode(.inline)
       .background(Color(UIColor.secondarySystemBackground))
//       .navigationBarBackButtonHidden(true)
//       .toolbar {
//          ToolbarItem(placement: .navigationBarLeading) {
//             Button {
//                navigateToNextView = true
//             } label: {
//                HStack {
//                   Image(systemName: "chevron.backward")
//                   Text("Zurück")
//                }
//             }
//          }
//       }
//       .navigationDestination(isPresented: $navigateToNextView) { Votings() }
    }
}

#Preview() {
//      @Previewable @State var path: [String] = ["VoteView"]
//   @Previewable @State var rootIsActive: Bool = false
   
   Votings_VotingResultView(voting: Voting(title: "Vereinsfarbe", question: "Welche Farbe soll die neue Vereinsfarbe werden?", startet_at: Date.now, is_open: true, meeting: MeetingTest(title: "Jahreshauptversammlung", start: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, status: .inSession), voting_options: [
      Voting_option(index: 0, text: "Enthaltung", count: 10),
      Voting_option(index: 1, text: "Rot", count: 10),
      Voting_option(index: 2, text: "Grün", count: 30),
      Voting_option(index: 3, text: "Blau", count: 50),
    ]), sampleIdentity: Identity(name: "Max Mustermann", votes: [Vote(voting: Voting(title: "Abstimmung2", question: "Welche Option soll gewählt werden 2?", startet_at: Calendar.current.date(byAdding: .minute, value: -15, to: Date())!, is_open: false, meeting: MeetingTest(title: "Jahreshauptversammlung", start: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, status: .inSession), voting_options: [
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
   ]), index: 0), Vote(voting: Voting(title: "Vereinsfarbe", question: "Welche Farbe soll die neue Vereinsfarbe werden?", startet_at: Date.now, is_open: true, meeting: MeetingTest(title: "Jahreshauptversammlung", start: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, status: .inSession), voting_options: [
      Voting_option(index: 0, text: "Enthaltung"),
      Voting_option(index: 1, text: "Rot"),
      Voting_option(index: 2, text: "Grün"),
      Voting_option(index: 3, text: "Blau"),
   ]), index: 3)]) )
}
