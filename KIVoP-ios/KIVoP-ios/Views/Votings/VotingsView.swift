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
//  Votings-VotingsOverview.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 08.11.24.
//

import SwiftUI
import Combine
import MeetingServiceDTOs

/// A view that displays all votings grouped by meetings
struct VotingsView: View {
   
   // MARK: - ViewModel & State Variables
   
   /// ViewModel responsible for managing voting data
   @StateObject var viewModel = VotingsViewModel()
   /// Stores the grouped and filtered votings, filtered by searchText
   @State var groupedVotingsFiltered: [(
      meetingName: String,
      votings: [(
         voting: GetVotingDTO,
         symbol: (status: String, color: Color)
      )]
   )] = []
   
   @State private var searchText = "" /// Holds the search text input
   @State private var selectedVoting: GetVotingDTO? /// Stores the selected voting when tapped
   @State private var isShowingVoteSheet = false /// Controls the presentation of the voting sheet
   @State private var navigateToResultView = false /// Controls navigation to the voting results view
   @State private var isLoading = false /// Indicates whether data is currently loading
   @State private var error: String? /// Stores an error message if fetching data fails
 
   // MARK: - Body
   
    var body: some View {
        ZStack {
           // List of grouped votings, filtered by searchText
            List {
               ForEach(groupedVotingsFiltered, id: \.meetingName) { group in
                  // display meeting name of associated meeting for each group of votings
                  Section(header: Text(group.meetingName)) {
                     ForEach(group.votings, id: \.voting.id) { item in
                        HStack {
                           // voting question
                           Text(item.voting.question)
                                .frame(maxWidth: .infinity, alignment: .leading)
                           // Displays the voting status symbol if available
                           if item.symbol.status != "" {
                                Image(systemName: item.symbol.status)
                                    .foregroundColor(item.symbol.color)
                            }
                        }
                        .contentShape(Rectangle()) // Expands tappable area
                        .onTapGesture {
                           selectedVoting = item.voting
                           // if voting is open and user hasn't voted yet, show vote sheet
                           if item.voting.isOpen && !item.voting.iVoted {
                              isShowingVoteSheet = true
                          } else {
                              navigateToResultView = true
                          }
                        }
                     }
                  }
               }
            }
            .navigationTitle("Abstimmungen")
           // fetch data and set groupedVotingsFiltered on refresh
            .refreshable {
               await viewModel.fetchVotings()
               groupedVotingsFiltered = viewModel.groupedVotings
            }
           // fetch data and set groupedVotingsFiltered on appear
            .onAppear {
               Task {
                  isLoading = true
                  await viewModel.fetchVotings()
                  groupedVotingsFiltered = viewModel.groupedVotings
                  isLoading = false
               }
            }
           // Vote Sheet
            .sheet(isPresented: $isShowingVoteSheet) {
                if let voting = selectedVoting {
                    Votings_VoteView(voting: voting) {
                       // after the user has voted, refresh the data
                        Task {
                           isLoading = true
                           await viewModel.fetchVotings()
                           groupedVotingsFiltered = viewModel.groupedVotings
                           isLoading = false
                        }
                       // and navigate to result view
                        navigateToResultView = true
                    }
                }
            }
           // navigation to voting results
            .navigationDestination(isPresented: $navigateToResultView) {
                if let voting = selectedVoting {
                    Votings_VotingResultView(voting: voting)
                }
            }
           // loading and error overlay
            .overlay {
                if isLoading { ProgressView("Loading...") }
                if let error = error { Text("Error: \(error)").foregroundColor(.red) }
            }
           // Search Bar: filter groupedVotings for searchText and store inside groupedVotingsFiltered
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Suchen")
            .onChange(of: searchText) { old, newText in
                if newText.isEmpty {
                    groupedVotingsFiltered = viewModel.groupedVotings
                } else {
                    groupedVotingsFiltered = viewModel.groupedVotings.compactMap { group in
                        let filteredVotings = group.votings.filter { item in
                            item.voting.question.localizedCaseInsensitiveContains(newText)
                        }
                        return filteredVotings.isEmpty ? nil : (meetingName: group.meetingName, votings: filteredVotings)
                    }
                }
            }

        }
    }

}


#Preview {
   NavigationStack {
      VotingsView()
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

