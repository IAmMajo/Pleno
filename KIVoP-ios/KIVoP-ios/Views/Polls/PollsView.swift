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

struct PollsView: View {
   @StateObject var viewModel = PollsViewModel()
   @State var pollsFiltered: [(poll: GetPollDTO, symbol: (status: String, color: Color))] = []
   
   @State private var searchText = ""
   @State private var selectedPoll: GetPollDTO?
   @State private var isShowingCreatePollSheet = false
   @State private var shouldRefreshPolls = false
   @State private var isShowingVoteSheet = false
   @State private var navigateToResultView = false
   @State private var isLoading = false
   @State private var error: String?
   
   func getDateColor(date: Date) -> Color {
      if date < Calendar.current.date(byAdding: .day, value: +1, to: Date())! && date > Date.now {
         return .orange
      } else {
         return Color(UIColor.secondaryLabel)
      }
   }
   
   var body: some View {
      if isLoading {
         ProgressView("Loading...")
      }
      ZStack {
         List {
            // Active polls section
            let activePolls = pollsFiltered
               .filter { $0.poll.isOpen}
               .sorted { $0.poll.startedAt > $1.poll.startedAt }
            
            if !activePolls.isEmpty {
               Section(header: Text("Aktiv")) {
                  ForEach(activePolls, id: \.poll.id) { item in
                     HStack {
                        VStack(alignment: .leading) {
                           Text(item.poll.question)
                              .frame(maxWidth: .infinity, alignment: .leading)
                           
                           Text("\(DateTimeFormatter.formatDate(item.poll.closedAt))")
                              .frame(maxWidth: .infinity, alignment: .leading)
                              .font(.callout)
                              .foregroundStyle(getDateColor(date: item.poll.closedAt))
                        }
                        
                        if !item.symbol.status.isEmpty {
                           Image(systemName: item.symbol.status)
                              .foregroundColor(item.symbol.color)
                        }
                     }
                     .contentShape(Rectangle())
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
            }
            // Completed polls section
            let completedPolls = pollsFiltered
               .filter { !$0.poll.isOpen}
               .sorted { $0.poll.startedAt > $1.poll.startedAt }
            
            if !completedPolls.isEmpty {
               Section(header: Text("Abgeschlossen")) {
                  ForEach(completedPolls, id: \.poll.id) { item in
                     HStack {
                        VStack(alignment: .leading) {
                           Text(item.poll.question)
                              .frame(maxWidth: .infinity, alignment: .leading)
                           
                           Text("\(DateTimeFormatter.formatDate(item.poll.closedAt))")
                              .frame(maxWidth: .infinity, alignment: .leading)
                              .font(.callout)
                              .foregroundStyle(getDateColor(date: item.poll.closedAt))
                        }
                        
                        if !item.symbol.status.isEmpty {
                           Image(systemName: item.symbol.status)
                              .foregroundColor(item.symbol.color)
                        }
                     }
                     .contentShape(Rectangle())
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
            }
         }
         .refreshable {
            await viewModel.fetchPolls()
            pollsFiltered = viewModel.polls
         }
         .onAppear {
            Task {
               isLoading = true
               await viewModel.fetchPolls()
               pollsFiltered = viewModel.polls
               isLoading = false
            }
         }
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
         .sheet(isPresented: $isShowingCreatePollSheet, onDismiss: {
             if shouldRefreshPolls {
                 shouldRefreshPolls = false
                 Task {
                     await viewModel.fetchPolls()
                     pollsFiltered = viewModel.polls
                 }
             }
         }) {
             Polls_CreatePollView(onSave: {
                 shouldRefreshPolls = true
                 isShowingCreatePollSheet = false
             })
             .interactiveDismissDisabled()
         }
         .sheet(isPresented: $isShowingVoteSheet) {
            if let poll = selectedPoll {
               Polls_VoteView(poll: poll) {
                  Task {
                     isLoading = true
                     await viewModel.fetchPolls()
                     pollsFiltered = viewModel.polls
                     isLoading = false
                  }
                  navigateToResultView = true
               }
            }
         }
         .navigationDestination(isPresented: $navigateToResultView) {
            if let poll = selectedPoll {
               Polls_PollResultView(poll: poll)
            }
         }
         .overlay {
            if isLoading { ProgressView("Loading...") }
            if let error = error { Text("Error: \(error)").foregroundColor(.red) }
         }
         .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Suchen")
         .onChange(of: searchText) { old, newValue in
            //             if newValue.isEmpty {
            //                polls.update(items: pollsOriginal.items)
            //             } else {
            //                polls.update(items: pollsOriginal.items.filter {
            //                   $0.pollDTO.question.localizedCaseInsensitiveContains(newValue)
            //                })
            //             }
         }
      }
      
   }
}

//struct PollRowView: View {
//    @ObservedObject var viewModel: PollViewModel
//
//    var body: some View {
//       HStack {
//          VStack {
//             Text(viewModel.pollDTO.question)
//                .frame(maxWidth: .infinity, alignment: .leading)
//             
//             Text("\(DateTimeFormatter.formatDate(viewModel.pollDTO.expirationDate))")
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .font(.callout)
//                .foregroundStyle(getDateColor(date: viewModel.pollDTO.expirationDate))
//          }
//          if !viewModel.statusSymbol.isEmpty {
//             Image(systemName: viewModel.statusSymbol)
//                .foregroundColor(viewModel.symbolColor)
//          }
//       }
//       .contentShape(Rectangle())
//    }
//}


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
