// This file is licensed under the MIT-0 License.
//
//  Polls-VoteView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 18.01.25.
//

import SwiftUI
import PollServiceDTOs

// A view that allows users to vote in a poll
struct Polls_VoteView: View {
      
   let poll: GetPollDTO
   
   @State private var isLoading = false // Indicates if a vote submission is in progress
   @State private var error: String? // Stores an error message if voting fails

   // Stores the selected options. Uses `Set` to manage multiple selections
   @State private var selection: Set<GetPollVotingOptionDTO> = []
   @State private var showingAlert = false // Controls the vote confirmation alert
   
   @Environment(\.dismiss) private var dismiss
   @Environment(\.colorScheme) var colorScheme
   
   // Closure executed after successfully casting a vote
   var onNavigate: () -> Void
   

   var body: some View {
          NavigationStack {
              VStack {
                 // Poll question
                  Text(poll.question)
                      .font(.title)
                      .fontWeight(.semibold)
                      .padding(.top).padding(.bottom, 2)
                      .padding(.leading).padding(.trailing)
                  Divider()
                 // Poll description
                  if !poll.description.isEmpty {
                      Text(poll.description)
                          .frame(maxWidth: .infinity, alignment: .center)
                          .padding(.leading).padding(.top, 2).padding(.trailing)
                  }

                 // MARK: - Poll Options List
                  List(poll.options, id: \.index) { option in
                      if option.index != UInt8(0) { // Skips abstention option
                          HStack {
                             // Selected option is highlighted with a filled checkmark
                              Image(systemName: selection.contains(option) ? "checkmark.circle.fill" : "circle")
                                  .foregroundStyle(selection.contains(option) ? .blue : .gray)
                              Text(option.text)
                          }
                          .listRowBackground(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .contentShape(Rectangle()) // Expands tap area for better usability
                          .onTapGesture {
                             handleSelection(for: option)
                          }
                      }
                  }

                 
                 // MARK: - Error Message Display (if any)
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

                 // MARK: - Vote Button
                  Button {
                      castVote()
                  } label: {
                      Text("Abstimmen")
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
   
   // MARK: - Helper Functions

   /// Handles selection of poll options
   /// - Parameter option: The selected voting option
   private func handleSelection(for option: GetPollVotingOptionDTO) {
      if selection.contains(option) {
         selection.remove(option)
      } else {
         if !poll.multiSelect, !selection.isEmpty {
            selection.removeAll() // Clears previous selection for single-choice polls
         }
         selection.insert(option)
      }
   }
   
   /// Submits the selected vote to the API
   private func castVote() {
      PollAPI.shared.voteInPoll(pollId: poll.id, optionIndex: getOptionIndex(selection: selection)) { result in
         DispatchQueue.main.async {
            switch result {
            case .success:
               print("Vote cast successfully!")
               dismiss() // Dismisses the voting view
               onNavigate() // Navigates to the results page
            case .failure(let error):
               self.error = "Fehler beim Voten für die Umfrage: \(error.localizedDescription)"
            }
         }
      }
   }
   
   /// Converts the selected options into an array of indices
   func getOptionIndex(selection: Set<GetPollVotingOptionDTO>) -> [UInt8] {
      if selection.isEmpty {
         return [UInt8(0)] // Default to abstention if nothing is selected
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
}
