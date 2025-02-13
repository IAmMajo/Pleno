// This file is licensed under the MIT-0 License.
//
//  PollsView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 17.01.25.
//

import SwiftUI

import SwiftUI
import Combine
import PollServiceDTOs

// A view displaying all polls, allowing users to vote or view results
struct PollsView: View {
   
   // MARK: - ViewModel & State Variables
   
   /// ViewModel responsible for managing poll data
   @StateObject var viewModel = PollsViewModel()
   /// Stores the displayed list of polls after filtering/searching
   @State var pollsFiltered: [(poll: GetPollDTO, symbol: (status: String, color: Color))] = []
   
   @State private var searchText = "" /// Holds the search input text
   @State private var selectedPoll: GetPollDTO? /// Stores the selected poll when tapped
   @State private var isShowingCreatePollSheet = false /// Controls whether the "Create Poll" sheet is displayed
   @State private var shouldRefreshPolls = false /// Indicates whether polls should be refreshed after creating a new one
   @State private var isShowingVoteSheet = false /// Controls whether the voting sheet is displayed
   @State private var navigateToResultView = false /// Controls navigation to the poll results view
   @State private var isLoading = false /// Indicates whether data is currently loading
   @State private var error: String? /// Stores an error message if fetching data fails
   
   // MARK: - Helper Functions
   
   /// Determines the color based on how close a poll is to closing (with closing date)
   func getDateColor(date: Date) -> Color {
      // returns orange if the poll closes within a day, otherwise secondary label color
      if date < Calendar.current.date(byAdding: .day, value: +1, to: Date())! && date > Date.now {
         return .orange
      } else {
         return Color(UIColor.secondaryLabel)
      }
   }
   
   // MARK: - Body
   var body: some View {
      if isLoading {
         ProgressView("Loading...")
      }
      ZStack {
         List {
            // Active polls section
            let activePolls = pollsFiltered
               .filter { $0.poll.isOpen} // Filters for open polls
               .sorted { $0.poll.startedAt > $1.poll.startedAt } // Sorts by start date (newest first)
             
            if !activePolls.isEmpty {
               Section(header: Text("Aktiv")) {
                  ForEach(activePolls, id: \.poll.id) { item in
                     pollRow(for: item) // Displays each poll row
                  }
               }
            }
            // Completed polls section
            let completedPolls = pollsFiltered
               .filter { !$0.poll.isOpen} // Filters for closed polls
               .sorted { $0.poll.startedAt > $1.poll.startedAt } // Sorts by start date (newest first)
            
            if !completedPolls.isEmpty {
               Section(header: Text("Abgeschlossen")) {
                  ForEach(completedPolls, id: \.poll.id) { item in
                     pollRow(for: item)
                  }
               }
            }
         }
         /// pull-to-refresh the polls list
         .refreshable {
            await fetchPolls()
         }
         /// Fetches polls when the view appears
         .onAppear {
            Task {
               isLoading = true
               await fetchPolls()
               isLoading = false
            }
         }
         /// Listens for updates in `viewModel.polls` and updates the displayed polls list
         .onReceive(viewModel.$polls) { newPolls in
             pollsFiltered = newPolls
         }
         .navigationTitle("Umfragen")
         .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
               Button(action: {
                  isShowingCreatePollSheet = true
               }) {
                  Label("Add Item", systemImage: "plus")
               }
            }
         }
         /// Opens a sheet for creating a new poll
         .sheet(isPresented: $isShowingCreatePollSheet, onDismiss: {
             if shouldRefreshPolls {
                 shouldRefreshPolls = false // Resets the refresh flag
                 Task {
                     await viewModel.fetchPolls()
                     pollsFiltered = viewModel.polls // Fetches updated polls after creation
                 }
             }
         }) {
            /// Presents the create poll view and ensures refresh after saving
             Polls_CreatePollView(onSave: {
                 shouldRefreshPolls = true // Marks that a refresh is needed
                 isShowingCreatePollSheet = false // Dismisses the sheet
             })
             .interactiveDismissDisabled() // Prevents accidental dismissal
         }
         /// Opens a voting sheet when a poll is selected
         .sheet(isPresented: $isShowingVoteSheet) {
            if let poll = selectedPoll {
               Polls_VoteView(poll: poll) {
                  Task {
                     isLoading = true
                     await viewModel.fetchPolls()
                     pollsFiltered = viewModel.polls
                     isLoading = false
                  }
                  navigateToResultView = true // Navigates to results after voting
               }
            }
         }
         /// Navigates to the poll results view when a poll is selected
         .navigationDestination(isPresented: $navigateToResultView) {
            if let poll = selectedPoll {
               Polls_PollResultView(poll: poll)
            }
         }
         .overlay {
            if isLoading { ProgressView("Loading...") }
            if let error = error { Text("Error: \(error)").foregroundColor(.red) }
         }
         /// Adds a search bar to filter polls question by searchText
         .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Suchen")
         .onChange(of: searchText) { old, newValue in
            if searchText.isEmpty {
               pollsFiltered = viewModel.polls
            } else {
               pollsFiltered = viewModel.polls.filter { item in
                  return item.poll.question.localizedCaseInsensitiveContains(searchText)
               }
            }
         }
      }
      
   }
   
   // MARK: - Fetch Polls
   /// Fetches polls from the ViewModel and updates the displayed list
   private func fetchPolls() async {
      await viewModel.fetchPolls()
      pollsFiltered = viewModel.polls
   }
   
   // MARK: - Poll Row View
   /// Creates a poll row that can be tapped to vote or view results
   /// - Parameter item: A tuple containing the poll and its UI symbol
   /// - Returns: A view representing a single poll entry
   private func pollRow(for item: (poll: GetPollDTO, symbol: (status: String, color: Color))) -> some View {
      HStack {
         VStack(alignment: .leading) {
            // Poll question
            Text(item.poll.question)
               .frame(maxWidth: .infinity, alignment: .leading)
            
            // Poll closedAt date
            Text("\(DateTimeFormatter.formatDate(item.poll.closedAt))")
               .frame(maxWidth: .infinity, alignment: .leading)
               .font(.callout)
               .foregroundStyle(getDateColor(date: item.poll.closedAt))
         }
         
         // Status Symbol
         if !item.symbol.status.isEmpty {
            Image(systemName: item.symbol.status)
               .foregroundColor(item.symbol.color)
         }
      }
      .contentShape(Rectangle()) // Expands tappable area
      .onTapGesture {
         selectedPoll = item.poll
         if item.poll.isOpen && !item.poll.iVoted {
            isShowingVoteSheet = true
         } else {
            navigateToResultView = true
         }
      }
   }
}

#Preview {
   NavigationStack {
      PollsView()
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
