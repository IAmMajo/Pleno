//
//  VotingDetail.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 09.11.24.
//

import SwiftUI

struct Votings_VotingDetail: View {
      
   let voting: Voting
   var sampleIdentity: Identity
   //var updatedSampleIdentity = sampleIdentity
//   lazy var updatedSampleIdentity: Identity = {
//      var identity = sampleIdentity
//
//   }
   @State private var selection: Voting_option?
   @State private var showingAlert = false
   @State private var navigateToNextView = false
//   @Binding var path: [String]
//   @Binding var rootIsActive: Bool
   
   func updateSampleIdentity(selection: Voting_option?) -> Identity {
      var identity = sampleIdentity
      identity.votes.append(Vote(voting: voting, index: selection?.index ?? 0))
      return identity
   }
   

   var body: some View {
         Group {
            VStack {
               Text("Welche Farbe soll die neue Vereinsfarbe werden?")
                  .font(.title)
                  .fontWeight(.semibold)
                  .padding(.top)
               
               List(voting.voting_options, id: \.self, selection: $selection) { option in
                  if option.index != 0 {
                     if selection == option {
                        Button(action: {}) {
                           HStack {
                              Image(systemName: "checkmark.circle.fill")
                                 .foregroundStyle(.blue)
                              Text(option.text)
                           }
                        }
                        .listRowBackground(Color(UIColor.systemBackground))
                     } else {
                        HStack {
                           Image(systemName: "circle")
                              .foregroundColor(.gray)
                           Text(option.text)
                        }
                     }
                  }
               }
               
               Button {
                  showingAlert = true
               } label: {
                  Text(selection != nil ? "Abstimmen" : "Enthalten")
                     .foregroundStyle(Color(UIColor.systemBackground))
                     .frame(maxWidth: .infinity)
               }
               .background(selection != nil ? Color.blue : Color.gray)
               .cornerRadius(10)
               .padding()
               .buttonStyle(.bordered)
               .controlSize(.large)
               .alert(isPresented:$showingAlert) {
                  Alert(
                     title: Text("Möchtest du wirklich abstimmen"),
                     message: Text("Du kannst deine Wahl danach nciht mehr ändern!"),
                     primaryButton: .default(Text("Abstimmen")) {
                        // update: user has voted
                        Task {
                           await BiometricAuth.executeIfSuccessfulAuth {
                              print("Successful Auth!")
                              navigateToNextView = true
//                              path.append("VotingResultView")
                           } otherwise: {
                              print("Failed Auth!")
                           }
                        }
                     },
                     secondaryButton: .cancel(Text("Zurück"))
                  )
               }
//               .navigationDestination(for: String.self) { pathValue in
//                  if pathValue == "VotingResultView" {
//                     Votings_VotingResultView(shouldPopToVotingsView: $rootIsActive, voting: voting, sampleIdentity: updateSampleIdentity(selection: selection ?? nil))
//                  }
//               }
                  .navigationDestination(isPresented: $navigateToNextView) {
                  Votings_VotingResultView(voting: voting, sampleIdentity: updateSampleIdentity(selection: selection ?? nil))
               }
            }
            .background(Color(UIColor.secondarySystemBackground))

         }
         .navigationBarTitleDisplayMode(.inline)
   }
}

#Preview {
//   @Previewable @State var path: [String] = ["VoteView"]
//   @Previewable @State var rootIsActive: Bool = false
   
   NavigationView {
      Votings_VotingDetail(voting: Voting(title: "Vereinsfarbe", question: "Welche Farbe soll die neue Vereinsfarbe werden?", startet_at: Date.now, is_open: true, meeting: MeetingTest(title: "Jahreshauptversammlung", start: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, status: .inSession), voting_options: [
         Voting_option(index: 0, text: "Enthaltung"),
         Voting_option(index: 1, text: "Rot"),
         Voting_option(index: 2, text: "Grün"),
         Voting_option(index: 3, text: "Blau"),
      ]),
                           sampleIdentity: Identity(name: "Max Mustermann", votes: [Vote(voting: Voting(title: "Abstimmung2", question: "Welche Option soll gewählt werden 2?", startet_at: Calendar.current.date(byAdding: .minute, value: -15, to: Date())!, is_open: false, meeting: MeetingTest(title: "Jahreshauptversammlung", start: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, status: .inSession), voting_options: [
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
                           ]), index: 0)]))
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
