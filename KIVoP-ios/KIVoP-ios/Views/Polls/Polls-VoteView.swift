//
//  Polls-VoteView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 18.01.25.
//

import SwiftUI
import MeetingServiceDTOs

struct Polls_VoteView: View {
      
   let poll: Poll
//   let votingResults: GetVotingResultsDTO
   
   @State private var isLoading = false
   @State private var error: String?

   @State private var selection: Set<PollOption> = []
   @State private var showingAlert = false
   
   @Environment(\.dismiss) private var dismiss
   
//   var onNavigate: (GetVotingResultsDTO) -> Void
   var onNavigate: () -> Void
   

   var body: some View {
         NavigationStack {
            VStack {
               Text(poll.question)
                  .font(.title)
                  .fontWeight(.semibold)
                  .padding(.top).padding(.bottom, 2)
                  .padding(.leading).padding(.trailing)
               Divider()
               if !poll.description.isEmpty {
                  Text(poll.description)
                     .frame(maxWidth: .infinity, alignment: .center)
                     .padding(.leading).padding(.top, 2).padding(.trailing)
               }
               
               List(poll.options, id: \.self, selection: $selection) { option in
                  if option.index != 0 {
                     HStack {
                        Image(systemName: selection.contains(option) ? "checkmark.circle.fill" : "circle")
                           .foregroundStyle(selection.contains(option) ? .blue : .gray)
                        Text(option.text)
                     }
                     .listRowBackground(Color(UIColor.systemBackground))
                     .frame(maxWidth: .infinity, alignment: .leading)
                     .contentShape(Rectangle())
                     .onTapGesture {
                        if selection.contains(option) {
                           selection.remove(option)
                        } else {
                           if !poll.multipleSelection, !selection.isEmpty {
                              selection.removeAll()
                           }
                           selection.insert(option)
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
//                  VotingService.shared.castVote(votingID: poll.id, index: selection != nil ? selection!.index : 0) { result in
//                      DispatchQueue.main.async {
//                          switch result {
//                          case .success:
                  print("Vote cast successfully!")
                  updateMyVote(selection: selection)
                  dismiss()
                  onNavigate()
//                          case .failure(let error):
//                             print("Failed to cast vote: \(error.localizedDescription)")
//                             self.error = error.localizedDescription
//                          }
//                      }
//                  }
               } label: {
                  Text(!selection.isEmpty ? "Abstimmen" : "Enthalten")
                     .foregroundStyle(Color(UIColor.systemBackground))
                     .frame(maxWidth: .infinity)
               }
               .background(!selection.isEmpty ? Color.blue : Color.gray)
               .cornerRadius(10)
               .padding()
               .buttonStyle(.bordered)
               .controlSize(.large)
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
 
   func updateMyVote(selection: Set<PollOption>) {
      if selection.isEmpty {
         PollStateTracker.saveVote(pollId: poll.id, voteIndex: 0)
      } else {
         for option in selection {
            PollStateTracker.saveVote(pollId: poll.id, voteIndex: option.index)
         }
      }
   }
}

#Preview {
   NavigationView {
      Polls_VoteView(poll: mockPolls[0], onNavigate: {})
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
