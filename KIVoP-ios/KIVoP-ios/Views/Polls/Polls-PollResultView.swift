// This file is licensed under the MIT-0 License.
//
//  Polls-PollResultView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 18.01.25.
//

import SwiftUI
import PollServiceDTOs

// A view that displays the results of a poll, including a pie chart and voting breakdown
struct Polls_PollResultView: View {
   let poll: GetPollDTO
   @State var pollResults: GetPollResultsDTO
   
   @State private var isLoading: Bool = false // Indicates if results are being loaded (only on appear of view)
   @State private var error: String? // Stores an error message if fetching results fails
   
   @Environment(\.dismiss) var dismiss
   
   @State var optionTextMap: [UInt8: String] = [:] // Maps option indices to their corresponding text
   
   // Initializes the view with a specific poll
   init(poll: GetPollDTO) {
      self.poll = poll
      self.pollResults = mockPollResults
   }
   
    var body: some View {
       ScrollView {
          VStack {
             // Poll pie chart
             ZStack {
                PollPieChartView(optionTextMap: optionTextMap, pollResults: pollResults)
                   .padding(.vertical)
                   .padding(.horizontal)
             }
             .background(Color(UIColor.systemBackground))
             .cornerRadius(10)
             .padding() .padding(.top, -8)
             
             // Poll closing date
             HStack {
                Image(systemName: "calendar.badge.clock")
                let string = poll.isOpen ? NSLocalizedString("Schließt:", comment: "") : NSLocalizedString("Geschlossen:", comment: "")
                Text("\(string) \(DateTimeFormatter.formatDate(poll.closedAt)), \(DateTimeFormatter.formatTime(poll.closedAt)) Uhr")
                   .frame(maxWidth: .infinity, alignment: .leading)
             }
             .foregroundStyle(Color(UIColor.secondaryLabel))
             .padding(.leading).padding(.bottom, 1)
             
             // Poll question
             Text(poll.question)
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading).padding(.trailing)
             
             // Poll description
             if !poll.description.isEmpty {
                ZStack {
                   Text(poll.description)
                      .padding()
                      .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
             }
             
             // Poll result list or no vites message
             if pollResults.totalCount != 0 {
                PollResultList(results: pollResults, optionTextMap: optionTextMap)
             } else {
                // Displays a message if no votes were cast
                ZStack {
                   HStack {
                      Image(systemName: "info.circle.fill")
                         .padding(.top, 1)
                      Text("Für diese Umfrage hat keiner abgestimmt.")
                   }
                   .foregroundStyle(Color(UIColor.label).opacity(0.6))
                   .padding()
                   .frame(maxWidth: .infinity, alignment: .leading)
                }.background(Color(UIColor.systemBackground))
                   .cornerRadius(10)
                   .padding(.horizontal) .padding(.top)
             }
             
          }
          .overlay {
             if isLoading { ProgressView("Loading...") }
             if let error = error { Text("Error: \(error)").foregroundColor(.red) }
          }
       }
       // pull-to-refresh
       .refreshable {
         fetchPollResults()
       }
       .onAppear {
          Task {
             isLoading = true
             fetchPollResults()
             isLoading = false
          }
          fillOptionTextMap(poll: poll) // Maps option indices to their text
       }
       .navigationTitle("Umfrage-Ergebnis")
       .navigationBarTitleDisplayMode(.inline)
       .background(Color(UIColor.secondarySystemBackground))
    }
   
   // MARK: - Helper Functions
   
   /// Fetches the poll results
   private func fetchPollResults() {
      PollAPI.shared.fetchPollResultsById(pollId: poll.id) { result in
         DispatchQueue.main.async {
            switch result {
            case .success(let resultsData):
               self.pollResults = resultsData
            case .failure(let error):
               self.error = error.localizedDescription
               print("Fehler beim Abrufen der Ergebnisse: \(error.localizedDescription)")
            }
         }
      }
   }
   
   /// Maps poll options to their respective text for display
   func fillOptionTextMap(poll: GetPollDTO) {
      for option in poll.options {
         optionTextMap[option.index] = option.text
      }
      optionTextMap[0] = ""
   }
}

// MARK: - Poll Result List
/// Displays a list of poll results with vote counts or percentages
struct PollResultList: View {
   @Environment(\.colorScheme) var colorScheme
   @State private var isCount = false // Toggles between count and percentage
   let results: GetPollResultsDTO
   let optionTextMap: [UInt8: String] // Maps option indices to their respective text values
   
   /// Retrieves the color for each poll option based on index
   func getColor(index: UInt8) -> Color {
      return colorMapping[index] ?? .gray
   }
   
   var body: some View {
      VStack(alignment: .leading, spacing: 7) {
         // Header: Total Votes & Toggle Switch
         HStack {
            Text("\(results.totalCount) Stimmen von \(results.identityCount) Personen")
               .foregroundStyle(Color(UIColor.secondaryLabel))
               .padding(.leading, 32)
            Spacer()
            Toggle(isOn: $isCount) { // Toggle to switch between count and percentage view
            }
            .toggleStyle(ImageToggleStyle())
            .padding(.trailing, 32) .padding(.bottom, 1)
         }
         
         // List of Poll Options
         VStack {
            ForEach(results.results, id: \.index) { result in
               PollResultRow(
                  pollResults: results,
                  result: result,
                  optionText: optionTextMap[result.index] ?? "",
                  getColor: getColor,
                  isCount: $isCount
               )
               .padding(.vertical, 6)
               
               // Add a divider between poll options
               if result.id != results.results.last?.id {
                  Divider()
                     .padding(.vertical, 2)
               }
            }
         }
         .padding(.horizontal)
         .padding(.vertical, 12)
         .background(Color(UIColor.systemBackground))
         .cornerRadius(10)
         .padding(.horizontal)
      }
      .padding(.vertical)
   }
}

/// A row displaying an individual poll result
/// Shows the option name, count/percentage, and user identities (if available)
struct PollResultRow: View {
   @State private var isCollapsed: Bool = true // Controls visibility of the identity list
   let pollResults: GetPollResultsDTO // Contains all poll results
   let result: GetPollResultDTO // Individual poll option result
   let optionText: String // The text for this option
   let getColor: (UInt8) -> Color // Function to retrieve color based on option index
   @Binding var isCount: Bool // Binds to toggle switch to show vote count or percentage
   
   var body: some View {
      VStack {
         HStack {
            // shows if the user has voted for this option
            // Color-coded checkmark if the user voted for this option
            Image(systemName: pollResults.myVotes.contains(where: {$0 == result.index})  ? "checkmark.circle.fill" : "circle.fill")
               .foregroundStyle(getColor(result.index))
            // option name
            Text(optionText)
            Spacer()
            if isCount {
               Text("\(result.count)")
                  .opacity(0.6)
            } else {
               Text("\(result.percentage, specifier: "%.2f")%")
                  .opacity(0.6)
            }
            
            // Expand/Collapse Button (if identities exist)
            if let identities = result.identities, !identities.isEmpty {
               Image(systemName: isCollapsed ? "chevron.forward" : "chevron.down")
                  .foregroundStyle(.blue)
            }
         }
         .contentShape(Rectangle()) // Increases tap area
         // expand/collapse identity list on tap
         .onTapGesture {
            if let identities = result.identities, !identities.isEmpty {
               withAnimation(.easeInOut(duration: 0.3)) {
                  isCollapsed.toggle()
               }
            }
         }
         
         //  Expanded Identity List (if applicable)
         if !isCollapsed, let identities = result.identities {
            VStack(alignment: .leading) {
               Divider()
                  .padding(.vertical, 4)
               // Display each voter identity
               ForEach(identities, id: \.id) { identity in
                  HStack {
                     Image(systemName: "checkmark.circle.fill") // Voter checkmark
                        .foregroundStyle(getColor(result.index).opacity(0.55).mix(with: .gray, by: 0.1))
                     Text(identity.name) // Voter's name
                  }
                  // Add divider between identity names
                  if identity.id != identities.last?.id {
                     Divider()
                        .padding(.top, 2) .padding(.bottom, 4)
                  }
               }
            }
            .padding(.leading, 25)
            .transition(
               .asymmetric(
                  insertion: .opacity.animation(.easeIn(duration: 0.1)),
                  removal: .opacity.animation(.easeOut(duration: 0.1))
               )
            )
            .animation(.easeInOut(duration: 0.5), value: isCollapsed) // Controls animation
         }
      }
   }
}

// MARK: - Extensions
/// Enables `GetIdentityDTO` to be used in SwiftUI lists and comparisons
extension GetIdentityDTO: @retroactive Identifiable {}
extension GetIdentityDTO: @retroactive Equatable {}
extension GetIdentityDTO: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public static func == (lhs: GetIdentityDTO, rhs: GetIdentityDTO) -> Bool {
        return lhs.id == rhs.id
    }
}

#Preview() {
}
