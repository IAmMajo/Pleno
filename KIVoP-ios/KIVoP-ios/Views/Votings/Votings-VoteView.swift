//
//  VotingDetail.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 09.11.24.
//

import SwiftUI
import MeetingServiceDTOs

struct Votings_VoteView: View {
      
   let voting: GetVotingDTO
   let votingResults: GetVotingResultsDTO

   @Environment(\.dismiss) private var dismiss

   @State private var selection: GetVotingOptionDTO?
   @State private var showingAlert = false
   
   var onNavigate: (GetVotingResultsDTO) -> Void
   

   var body: some View {
         NavigationStack {
            VStack {
               Text(voting.question)
                  .font(.title)
                  .fontWeight(.semibold)
                  .padding(.top)
               
               List(voting.options, id: \.self, selection: $selection) { option in
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
                              dismiss()
                              onNavigate(updateMyVote(selection: selection ?? nil))
                           } otherwise: {
                              print("Failed Auth!")
                           }
                        }
                     },
                     secondaryButton: .cancel(Text("Zurück"))
                  )
               }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen", action: { dismiss() })
                }
            }

         }
         .navigationBarTitleDisplayMode(.inline)
   }
   
   
   func updateMyVote(selection: GetVotingOptionDTO?) -> GetVotingResultsDTO {
      var results = votingResults
      results.myVote = selection?.index
      return results
   }
}

#Preview {
   NavigationView {
      var votingsView: VotingsView = .init()
      
      Votings_VoteView(voting: votingsView.mockVotings[0], votingResults: votingsView.mockVotingResults, onNavigate: {results in})
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
