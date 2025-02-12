// This file is licensed under the MIT-0 License.
//
//  VotingDetail.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 09.11.24.
//

import SwiftUI
import MeetingServiceDTOs

/// A view that allows the user to cast their vote in a voting process
struct Votings_VoteView: View {
      
   let voting: GetVotingDTO
   @State private var isLoading = false
   @State private var error: String?

   @State private var selection: GetVotingOptionDTO? // Stores the user's selected voting option
   @State private var showingAlert = false // Controls the confirmation alert when voting
   
   @Environment(\.dismiss) private var dismiss
   @Environment(\.colorScheme) var colorScheme
   
   var onNavigate: () -> Void // Closure to handle navigation after a successful vote
   

   var body: some View {
         NavigationStack {
            VStack {
               // Voting question
               Text(voting.question)
                  .font(.title)
                  .fontWeight(.semibold)
                  .padding(.top).padding(.bottom, 2)
                  .padding(.leading).padding(.trailing)
               Divider()
               // Voting description
               if !voting.description.isEmpty {
                  Text(voting.description)
                     .frame(maxWidth: .infinity, alignment: .center)
                     .padding(.leading).padding(.top, 2).padding(.trailing)
               }
               
               // Voting Options List
               List(voting.options, id: \.self, selection: $selection) { option in
                  if option.index != 0 { // Skips abstention option in the list
                     if selection == option {
                        // Selected option is highlighted with a filled checkmark
                        Button(action: {}) {
                           HStack {
                              Image(systemName: "checkmark.circle.fill")
                                 .foregroundStyle(.blue)
                              Text(option.text)
                           }
                        }
                        .listRowBackground(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
                     } else {
                        // Non-selected options show an empty circle
                        HStack {
                           Image(systemName: "circle")
                              .foregroundColor(.gray)
                           Text(option.text)
                        }
                     }
                  }
               }
               
               // MARK: - Error Message Display (if any)
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
               
               // MARK: - Vote Button
               Button {
                  showingAlert = true
               } label: {
                  Text(selection != nil ? "Abstimmen" : "Enthalten") // Changes button text based on selection
                     .foregroundStyle(Color(UIColor.systemBackground))
                     .frame(maxWidth: .infinity)
               }
               .background(selection != nil ? Color.blue : Color.gray) // Changes button color based on selection
               .cornerRadius(10)
               .padding()
               .buttonStyle(.bordered)
               .controlSize(.large)
               // MARK: - Voting Confirmation Alert
               .alert(isPresented:$showingAlert) {
                  Alert(
                     title: Text("Möchtest du wirklich abstimmen?"),
                     message: Text("Du kannst deine Wahl danach nicht mehr ändern!"),
                     primaryButton: .default(Text("Abstimmen")) {
                        Task {
                           // authenticate user via FaceID
                           await BiometricAuth.executeIfSuccessfulAuth {
                              print("Successful Auth!")
                              // submit vote if authentication was successful
                              submitVote()
                           } otherwise: {
                              print("Failed Auth!")
                           }
                        }
                     },
                     secondaryButton: .cancel(Text("Zurück"))
                  )
               }
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
      
   /// Submits the selected vote and handles response
   private func submitVote() {
      // cast vote
      VotingService.shared.castVote(votingID: voting.id, index: selection != nil ? selection!.index : 0) { result in
         DispatchQueue.main.async {
            switch result {
            case .success:
               print("Vote cast successfully!")
               dismiss() // Dismisses the voting view
               onNavigate() // Navigates to the voting results
            case .failure(let error):
               print("Failed to cast vote: \(error.localizedDescription)")
               self.error = error.localizedDescription // Displays the error message
            }
         }
      }
   }
}

#Preview {
   NavigationView {
      Votings_VoteView(voting: mockVotings[0], onNavigate: {})
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
