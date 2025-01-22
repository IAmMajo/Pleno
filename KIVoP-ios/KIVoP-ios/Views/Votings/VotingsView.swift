//
//  Votings-VotingsOverview.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 08.11.24.
//

import SwiftUI
import Combine
import MeetingServiceDTOs

struct VotingsView: View {
   @StateObject var viewModel = VotingsViewModel()
   @State var groupedVotingsFiltered: [(
      meetingName: String,
      votings: [(
         voting: GetVotingDTO,
         symbol: (status: String, color: Color)
      )]
   )] = []
    @State private var searchText = ""
   @State private var selectedVoting: GetVotingDTO?
    @State private var isShowingVoteSheet = false
    @State private var navigateToResultView = false
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        ZStack {
            List {
               ForEach(groupedVotingsFiltered, id: \.meetingName) { group in
                  Section(header: Text(group.meetingName)) {
                     ForEach(group.votings, id: \.voting.id) { item in
                        HStack {
                           Text(item.voting.question)
                                .frame(maxWidth: .infinity, alignment: .leading)
                           if item.symbol.status != "" {
                                Image(systemName: item.symbol.status)
                                    .foregroundColor(item.symbol.color)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                           selectedVoting = item.voting
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
//            .id(forceRefresh)
            .navigationTitle("Abstimmungen")
            .refreshable {
               await viewModel.fetchVotings()
               groupedVotingsFiltered = viewModel.groupedVotings
            }
            .onAppear {
               Task {
                  isLoading = true
                  await viewModel.fetchVotings()
                  groupedVotingsFiltered = viewModel.groupedVotings
                  isLoading = false
               }
            }
            .sheet(isPresented: $isShowingVoteSheet) {
                if let voting = selectedVoting {
                    Votings_VoteView(voting: voting) {
                        Task {
//                            await voting.refreshAfterVote()
                           isLoading = true
                           await viewModel.fetchVotings()
                           groupedVotingsFiltered = viewModel.groupedVotings
                           isLoading = false
                        }
                        navigateToResultView = true
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToResultView) {
                if let voting = selectedVoting {
                    Votings_VotingResultView(voting: voting)
                }
            }
            .overlay {
                if isLoading { ProgressView("Loading...") }
                if let error = error { Text("Error: \(error)").foregroundColor(.red) }
            }
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

