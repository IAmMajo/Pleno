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
//   let votingResults: GetVotingResultsDTO
   
   @State private var isLoading = false
   @State private var error: String?

   @State private var selection: GetVotingOptionDTO?
   @State private var showingAlert = false
   
   @Environment(\.dismiss) private var dismiss
   
//   var onNavigate: (GetVotingResultsDTO) -> Void
   var onNavigate: () -> Void
   

   var body: some View {
         NavigationStack {
            VStack {
               Text(voting.question)
                  .font(.title)
                  .fontWeight(.semibold)
                  .padding(.top).padding(.bottom, 2)
                  .padding(.leading).padding(.trailing)
               Divider()
               if !voting.description.isEmpty {
                  Text(voting.description)
                     .frame(maxWidth: .infinity, alignment: .center)
                     .padding(.leading).padding(.top, 2).padding(.trailing)
               }
               
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
               
               if error != nil {
                  VStack(alignment: .center, spacing: 8) {
                     Text("Abstimmen nicht möglich")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red.opacity(0.8).mix(with: Color(UIColor.label), by: 0.1))
                     Text(NSLocalizedString(error ?? "Unbekannter Fehler.", comment: ""))
                        .foregroundStyle(.red.opacity(0.8).mix(with: Color(UIColor.label), by: 0.5))
                        .multilineTextAlignment(.center)
                  }
                  .padding(.horizontal)
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
                     title: Text("Möchtest du wirklich abstimmen?"),
                     message: Text("Du kannst deine Wahl danach nciht mehr ändern!"),
                     primaryButton: .default(Text("Abstimmen")) {
                        Task {
                           await BiometricAuth.executeIfSuccessfulAuth {
                              print("Successful Auth!")
                              VotingService.shared.castVote(votingID: voting.id, index: selection != nil ? selection!.index : 0) { result in
                                  DispatchQueue.main.async {
                                      switch result {
                                      case .success:
                                         print("Vote cast successfully!")
                                         dismiss()
                                         updateMyVote(selection: selection ?? nil)
                                         onNavigate()
//                                         onNavigate(updateMyVote(selection: selection ?? nil))
                                      case .failure(let error):
                                         print("Failed to cast vote: \(error.localizedDescription)")
                                         self.error = error.localizedDescription
                                      }
                                  }
                              }
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
 
   func updateMyVote(selection: GetVotingOptionDTO?) {
      
      VotingStateTracker.saveVote(votingId: voting.id, voteIndex: selection?.index ?? 0)

//      var results = votingResults
//      results.myVote = selection?.index
//      return results
   }
}

#Preview {
   NavigationView {
//      var votingsView: VotingsView = .init()
      
      Votings_VoteView(voting: /*votingsView.*/mockVotings[0], onNavigate: {})
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
