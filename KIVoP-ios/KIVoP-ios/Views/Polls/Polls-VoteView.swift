// This file is licensed under the MIT-0 License.
//
//  Polls-VoteView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 18.01.25.
//

import SwiftUI
import PollServiceDTOs

struct Polls_VoteView: View {
      
   let poll: GetPollDTO
//   let votingResults: GetVotingResultsDTO
   
   @State private var isLoading = false
   @State private var error: String?

   @State private var selection: Set<GetPollVotingOptionDTO> = []
   @State private var showingAlert = false
   
   @Environment(\.dismiss) private var dismiss
   @Environment(\.colorScheme) var colorScheme
   
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

                  List(poll.options, id: \.index) { option in
                      if option.index != UInt8(0) { // Explicitly compare types
                          HStack {
                              Image(systemName: selection.contains(option) ? "checkmark.circle.fill" : "circle")
                                  .foregroundStyle(selection.contains(option) ? .blue : .gray)
                              Text(option.text)
                          }
                          .listRowBackground(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .contentShape(Rectangle())
                          .onTapGesture {
                              if selection.contains(option) {
                                  selection.remove(option)
                              } else {
                                  if !poll.multiSelect, !selection.isEmpty {
                                      selection.removeAll()
                                  }
                                  selection.insert(option)
                              }
                          }
                      }
                  }

                  if let error = error {
                      VStack(alignment: .center, spacing: 8) {
                          Text("Abstimmen nicht möglich")
                              .font(.title3)
                              .fontWeight(.semibold)
                              .foregroundStyle(.red.opacity(0.8).mix(with: Color(UIColor.label), by: 0.1))
                          Text(NSLocalizedString(error, comment: ""))
                              .foregroundStyle(.red.opacity(0.8).mix(with: Color(UIColor.label), by: 0.5))
                              .multilineTextAlignment(.center)
                      }
                      .padding(.horizontal)
                  }

                  Button {
                      PollAPI.shared.voteInPoll(pollId: poll.id, optionIndex: getOptionIndex(selection: selection)) { result in
                          DispatchQueue.main.async {
                              switch result {
                              case .success:
                                  print("Vote cast successfully!")
                                  dismiss()
                                  onNavigate()
                              case .failure(let error):
                                  self.error = "Fehler beim Voten für die Umfrage: \(error.localizedDescription)"
                              }
                          }
                      }
                  } label: {
                      Text(!selection.isEmpty ? "Abstimmen" : "Abstimmen")
                          .foregroundStyle(Color(UIColor.systemBackground))
                          .frame(maxWidth: .infinity)
                  }
                  .background(!selection.isEmpty ? Color.blue : Color.gray)
                  .cornerRadius(10)
                  .padding()
                  .buttonStyle(.bordered)
                  .controlSize(.large)
              }
              .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
              .toolbar {
                  ToolbarItem(placement: .cancellationAction) {
                      Button("Abbrechen", action: { dismiss() })
                  }
              }
          }
          .navigationBarTitleDisplayMode(.inline)
      }
   
   func getOptionIndex(selection: Set<GetPollVotingOptionDTO>) -> [UInt8] {
      if selection.isEmpty {
         return [UInt8(0)]
      } else {
         var array: [UInt8] = []
         for option in selection {
            array.append(UInt8(option.index))
         }
         return array
      }
   }

}

#Preview {
//   NavigationView {
//      Polls_VoteView(poll: mockPolls[0], onNavigate: {})
//      .toolbar {
//         ToolbarItem(placement: .navigationBarLeading) {
//            Button {
//               } label: {
//                  HStack {
//                     Image(systemName: "chevron.backward")
//                     Text("Zurück")
//                  }
//               }
//            }
//         }
//   }
}
