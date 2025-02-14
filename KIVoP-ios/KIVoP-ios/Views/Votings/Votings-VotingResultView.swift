// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//
//  Votings-VotingResultView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 15.11.24.
//

import SwiftUI
import LocalAuthentication
import MeetingServiceDTOs

/// A view displaying the results of a voting process, including live status and vote breakdown
struct Votings_VotingResultView: View {
   
   // MARK: - Environment & State Variables
   @Environment(\.colorScheme) var colorScheme
   @StateObject private var webSocketService = WebSocketService() // Handles live updates via WebSockets
   @StateObject private var meetingViewModel = MeetingViewModel() // Fetches meeting-related data
   
   let voting: GetVotingDTO // The voting object containing question and options
   @State var votingResults: GetVotingResultsDTO // Stores the results of the voting
   @State var meetingName = "" // Holds the meeting name associated with the voting
   
   @State private var isLoading = false
   @State private var error: String?
   @State private var resultsLoaded: Bool = false // Tracks if results have been loaded successfully
   @State private var isLiveStatusAvailable: Bool = false // Checks if a live voting session is still active
   
   @State var optionTextMap: [UInt8: String] = [:] // Maps option indices to their respective texts
   
   // MARK: - Initializer
   /// Initializes the view with a specific voting object
   init(voting: GetVotingDTO) {
      self.voting = voting
      self.votingResults = mockVotingResults // Mock data for initialization
   }
   
   // MARK: - Body
    var body: some View {
       ScrollView {
          // if voting is still open (WebSocket connection is successful) or voting results loaded display live status or results
          if (isLiveStatusAvailable || resultsLoaded) {
             VStack {
                ZStack {
                   if isLiveStatusAvailable {
                      // Displays a live voting status view, using the WebSocket, if voting is still open
                      VotingLiveStatusView(votingId: voting.id) {
                         Task {
                            self.isLiveStatusAvailable = false
                            await loadVotingResults(voting: voting)
                         }
                      }
                      .padding(.vertical) .padding(.top, -5)
                   } else {
                      // Shows a pie chart with voting results
                      PieChartView(optionTextMap: optionTextMap, votingResults: votingResults)
                         .padding(.vertical)
                         .padding(.horizontal)
                   }
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .padding() .padding(.top, -8)

                // Meeting name
                HStack {
                   Image(systemName: "person.bust.fill")
                   Text(meetingName)
//                   Text("Sitzungsname")
                      .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundStyle(Color(UIColor.secondaryLabel))
                .padding(.leading).padding(.bottom, 1)
                
                // Voting question
                Text(voting.question)
                   .font(.title2)
                   .fontWeight(.bold)
                   .frame(maxWidth: .infinity, alignment: .leading)
                   .padding(.leading).padding(.trailing)
                   
                // Voting description
                if !voting.description.isEmpty {
                   ZStack {
                      Text(voting.description)
                         .padding()
                         .frame(maxWidth: .infinity, alignment: .leading)
                   }
                   .background(Color(UIColor.systemBackground))
                   .cornerRadius(10)
                   .padding(.horizontal)
                }
                
                // Shows a message if the voting is still open and the user has voted
                if isLiveStatusAvailable {
                   ZStack {
                      HStack {
                         Image(systemName: "info.circle.fill")
                            .padding(.top, 1)
                         Text("Die Abstimmung läuft noch. Du hast bereits abgestimmt.")
                      }
                      .foregroundStyle(Color(UIColor.label).opacity(0.6))
                      .padding()
                      .frame(maxWidth: .infinity, alignment: .leading)
                   }.background(Color(UIColor.systemBackground))
                      .cornerRadius(10)
                      .padding(.horizontal) .padding(.top)
                } else if votingResults.totalCount != 0 {
                   // Displays the voting results list if votes have been cast (and voting is closed)
                   VotingResultList(results: votingResults, optionTextMap: optionTextMap)
                } else {
                   // Shows a message if no one has voted (and voting is closed)
                   ZStack {
                      HStack {
                         Image(systemName: "info.circle.fill")
                            .padding(.top, 1)
                         Text("Für diese Abstimmung hat keiner abgestimmt.")
                      }
                      .foregroundStyle(Color(UIColor.label).opacity(0.6))
                      .padding()
                      .frame(maxWidth: .infinity, alignment: .leading)
                   }.background(Color(UIColor.systemBackground))
                      .cornerRadius(10)
                      .padding(.horizontal) .padding(.top)
                }
             }
          } else if isLoading {
             ProgressView("Loading...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
          } else {
             ContentUnavailableView(
               "Die Abstimmungsergebnisse konnten nicht geladen werden",
               systemImage: "chart.pie.fill"
             )
          }
       }
       .refreshable {
          self.isLiveStatusAvailable = await isLiveStatusAvailable(votingId: voting.id)
          if !isLiveStatusAvailable {
             await loadVotingResults(voting: voting)
          }
       }
       // check if live status is available (voting is open) and load voting results if it isn't
       .onAppear {
          Task {
             isLoading = true
             self.isLiveStatusAvailable = await isLiveStatusAvailable(votingId: voting.id)
             if !isLiveStatusAvailable {
                await loadVotingResults(voting: voting)
             }
             await loadMeetingName(voting: voting) // load meeting name of voting
          }
          fillOptionTextMap(voting: voting) // fill the option-text map
          isLoading = false
       }
       .navigationTitle(isLiveStatusAvailable ? "Live-Status" : "Abstimmungs-Ergebnis")
       .navigationBarTitleDisplayMode(.inline)
       .background(Color(UIColor.secondarySystemBackground))
    }
   
   // MARK: - Helper Functions
   
   /// Checks if a live voting session is available via WebSocket
   private func isLiveStatusAvailable(votingId: UUID) async -> Bool {
      await withCheckedContinuation { continuation in
         webSocketService.connect(to: votingId)
         // Wait for the WebSocket to receive messages
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let liveStatus = webSocketService.liveStatus, !liveStatus.isEmpty {
               webSocketService.disconnect()
               continuation.resume(returning: true)
            } else if webSocketService.votingResults != nil {
               webSocketService.disconnect()
               continuation.resume(returning: false)
            } else if webSocketService.errorMessage != nil {
               webSocketService.disconnect()
               continuation.resume(returning: false)
            } else {
               webSocketService.disconnect()
               continuation.resume(returning: false)
            }
         }
      }
   }

   /// Loads voting results
   private func loadVotingResults(voting: GetVotingDTO) async {
      VotingService.shared.fetchVotingResults(votingId: voting.id) { result in
         DispatchQueue.main.async {
            switch result {
            case .success(let results):
               self.votingResults = results
               resultsLoaded = true
            case .failure(let error):
               print("Fehler beim Abrufen der Ergebnisse: \(error.localizedDescription)")
            }
         }
      }
   }
   
   /// Loads the meeting name for the voting
   private func loadMeetingName(voting: GetVotingDTO) async {
      do {
         let meeting = try await meetingViewModel.fetchMeeting(byId: voting.meetingId)
         meetingName = meeting.name
      } catch {
         print("Error fetching meeting: \(error.localizedDescription)")
      }
   }
   
   /// Fills the map with voting option texts
   func fillOptionTextMap(voting: GetVotingDTO) {
      for option in voting.options {
         optionTextMap[option.index] = option.text
      }
      optionTextMap[0] = "Enthaltung"
   }

}

// MARK: - Voting Result List

/// A view displaying the list of voting results.
/// Shows each option, its vote count/percentage, and expandable details if identities are available
struct VotingResultList: View {
   @Environment(\.colorScheme) var colorScheme
   @State private var isCount = false // Toggles between displaying vote count vs. percentage
   let results: GetVotingResultsDTO
   let optionTextMap: [UInt8: String] // Maps option indices to their respective text values
   
   /// Retrieves the color for each voting option based on index
   func getColor(index: UInt8) -> Color {
      return colorMapping[index] ?? .gray
   }
   
   var body: some View {
      VStack(alignment: .leading, spacing: 7) {
         // Header: Total Votes & Toggle Switch
         HStack {
            Text("Stimmen (\(results.totalCount))")
               .foregroundStyle(Color(UIColor.secondaryLabel))
               .padding(.leading, 32)
            Spacer()
            Toggle(isOn: $isCount) { // Toggle to switch between count and percentage view
            }
            .toggleStyle(ImageToggleStyle()) // Custom toggle switch
            .padding(.trailing, 32) .padding(.bottom, 1)
         }
         
         // List of Voting Options
         VStack {
            ForEach(results.results, id: \.id) { result in
               VotingResultRow(
                  votingResults: results,
                  result: result,
                  optionText: optionTextMap[result.index] ?? "",
                  getColor: getColor,
                  isCount: $isCount
               )
               .padding(.vertical, 6)
               
               // Add a divider between voting options
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

/// A row displaying an individual voting result
/// Shows the option name, count/percentage, and user identities (if available)
struct VotingResultRow: View {
   @State private var isCollapsed: Bool = true // Controls visibility of the identity list
   let votingResults: GetVotingResultsDTO // Contains all voting results
   let result: GetVotingResultDTO // Individual voting option result
   let optionText: String // The text for this option
   let getColor: (UInt8) -> Color // Function to retrieve color based on option index
   @Binding var isCount: Bool // Binds to toggle switch to show vote count or percentage
   
   var body: some View {
      VStack {
         HStack {
            // shows if the user has voted for this option
            // Color-coded checkmark if the user voted for this option
            Image(systemName: votingResults.myVote == result.index ? "checkmark.circle.fill" : "circle.fill")
               .foregroundStyle(getColor(result.index))
            // option name
            Text(optionText)
            Spacer()
            // vote count / percentage
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

/// A custom toggle switch to switch between percentage and count view
struct ImageToggleStyle: ToggleStyle {
   var percentImage = "percent" // Icon for percentage
   var countImage = "numbers" // Icon for count view
   
   func makeBody(configuration: Configuration) -> some View {
      HStack {
         RoundedRectangle(cornerRadius: 28) // Background of the toggle
            .fill(configuration.isOn ? Color(.systemGray3).mix(with: .blue, by: 0.4) : Color(.systemGray3).mix(with: .blue, by: 0.4))
            .overlay {
               Circle()
                  .fill(.white) // Foreground of the toggle
                  .padding(3)
                  .overlay {
                     Image(systemName: configuration.isOn ? countImage : percentImage) // Display icon based on state
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12)
                        .foregroundColor(configuration.isOn ? Color(.systemGray5).mix(with: .blue, by: 0.8) : Color(.systemGray4).mix(with: .blue, by: 0.5))
                  }
                  .offset(x: configuration.isOn ? 10 : -10) // Moves the circle left/right
            }
            .frame(width: 42, height: 26)
            .onTapGesture {
               withAnimation(.spring()) {
                  configuration.isOn.toggle() // Switch toggle state
               }
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
   Votings_VotingResultView(voting: mockVotings[0])
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
