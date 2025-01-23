//
//  PollsView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 17.01.25.
//

import SwiftUI

import SwiftUI
import Combine
import MeetingServiceDTOs

class ObservablePollsArray<T: ObservableObject>: ObservableObject {
    @Published var items: [T] {
        didSet {
            observeItems()
        }
    }

    private var cancellables: [AnyCancellable] = []

    init(items: [T] = []) {
        self.items = items
        observeItems()
    }

    private func observeItems() {
        cancellables = items.map { item in
            item.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }
        }
    }

    func update(items: [T]) {
        self.items = items
    }
}

struct PollsView: View {
   @StateObject private var votingService = VotingService.shared
   
   @StateObject private var polls: ObservablePollsArray<PollViewModel> = ObservablePollsArray()
   @StateObject private var pollsOriginal: ObservablePollsArray<PollViewModel> = ObservablePollsArray()
   
   @State private var searchText = ""
   @State private var selectedPoll: PollViewModel?
   @State private var isShowingCreatePollSheet = false
   @State private var isShowingVoteSheet = false
   @State private var navigateToResultView = false
   @State private var isLoading = false
   @State private var error: String?

    var body: some View {
       ZStack {
          List {
             if polls.items.contains(where: {$0.pollDTO.isOpen == true}) {
                Section(header: Text("Aktiv")) {
                   ForEach(
                     polls.items
                        .filter { $0.pollDTO.isOpen == true && $0.pollDTO.startedAt != nil }
                        .sorted { $0.pollDTO.startedAt! > $1.pollDTO.startedAt! },
                     id: \.id) { poll in
                        PollRowView(viewModel: poll)
                           .onTapGesture {
                              handlePollSelection(poll)
                           }
                     }
                }
             }
             if polls.items.contains(where: {$0.pollDTO.isOpen == false}) {
                Section(header: Text("Abgeschlossen")) {
                   ForEach(
                     polls.items
                        .filter { $0.pollDTO.isOpen == false && $0.pollDTO.startedAt != nil }
                        .sorted { $0.pollDTO.startedAt! > $1.pollDTO.startedAt! },
                     id: \.id) { poll in
                        PollRowView(viewModel: poll)
                           .onTapGesture {
                              handlePollSelection(poll)
                           }
                     }
                }
             }
          }
          //            .id(forceRefresh)
          .refreshable { await loadPolls() }
          .onAppear { Task { await loadPolls() } }
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
          .sheet(isPresented: $isShowingCreatePollSheet) {
             Polls_CreatePollView(onPollCreated: { newPoll in
//                var fetchedPolls = mockPolls
//                fetchedPolls.append(newPoll)
//                 let updatedPolls = fetchedPolls.map { dto in
//                     if let existing = polls.items.first(where: { $0.id == dto.id }) {
//                         existing.update(pollDTO: dto)
//                         return existing
//                     } else {
//                         return PollViewModel(poll: dto)
//                     }
//                 }
//                polls.update(items: updatedPolls)
//                pollsOriginal.update(items: updatedPolls)
            })
                .interactiveDismissDisabled()
          }
          .sheet(isPresented: $isShowingVoteSheet) {
             if let poll = selectedPoll {
                Polls_VoteView(poll: poll.pollDTO)
                {
                   Task {
                      await poll.refreshAfterVote()
                   }
                   navigateToResultView = true
                }
             }
          }
          .navigationDestination(isPresented: $navigateToResultView) {
             if let poll = selectedPoll {
                Polls_PollResultView(poll: poll.pollDTO, onPollEnd: { updatedPoll in
                   if let index = mockPolls.firstIndex(where: { $0.id == updatedPoll.id }) {
                      var pollsUpdated = mockPolls
                      pollsUpdated.remove(at: index)
                      var poll = updatedPoll
                      poll.isOpen = false
                      
                      var fetchedPolls = pollsUpdated
                      fetchedPolls.append(poll)
                      let updatedPolls = fetchedPolls.map { dto in
                         if let existing = polls.items.first(where: { $0.id == dto.id }) {
                            existing.update(pollDTO: dto)
                            return existing
                         } else {
                            return PollViewModel(poll: dto)
                         }
                      }
                      polls.update(items: updatedPolls)
                      pollsOriginal.update(items: updatedPolls)
                   }
                })
             }
          }
          .overlay {
             if isLoading { ProgressView("Loading...") }
             if let error = error { Text("Error: \(error)").foregroundColor(.red) }
          }
          .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Suchen")
          .onChange(of: searchText) { old, newValue in
             if newValue.isEmpty {
                polls.update(items: pollsOriginal.items)
             } else {
                polls.update(items: pollsOriginal.items.filter {
                   $0.pollDTO.question.localizedCaseInsensitiveContains(newValue)
                })
             }
          }
       }
    }

    private func handlePollSelection(_ poll: PollViewModel) {
        selectedPoll = poll
       if poll.pollDTO.isOpen && !PollStateTracker.hasVotedForPoll(for: poll.id) {
            isShowingVoteSheet = true
        } else {
            navigateToResultView = true
        }
    }

    private func loadPolls() async {
        isLoading = true
        do {
//            let fetchedPolls = try await votingService.fetchVotings()
           let fetchedPolls = mockPolls
            let updatedPolls = fetchedPolls.map { dto in
                if let existing = polls.items.first(where: { $0.id == dto.id }) {
                    existing.update(pollDTO: dto)
                    return existing
                } else {
                    return PollViewModel(poll: dto)
                }
            }
           polls.update(items: updatedPolls)
           pollsOriginal.update(items: updatedPolls)
        } catch {
            self.error = "Failed to load polls: \(error.localizedDescription)"
        }
        isLoading = false
    }
   
}

struct PollRowView: View {
    @ObservedObject var viewModel: PollViewModel

    var body: some View {
       HStack {
          VStack {
             Text(viewModel.pollDTO.question)
                .frame(maxWidth: .infinity, alignment: .leading)
             
             Text("\(DateTimeFormatter.formatDate(viewModel.pollDTO.expirationDate))")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.callout)
                .foregroundStyle(getDateColor(date: viewModel.pollDTO.expirationDate))
          }
          if !viewModel.statusSymbol.isEmpty {
             Image(systemName: viewModel.statusSymbol)
                .foregroundColor(viewModel.symbolColor)
          }
       }
       .contentShape(Rectangle())
    }
   
   func getDateColor(date: Date) -> Color {
      if date < Calendar.current.date(byAdding: .day, value: +1, to: Date())! && date > Date.now {
         return .orange
      } else {
         return Color(UIColor.secondaryLabel)
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
