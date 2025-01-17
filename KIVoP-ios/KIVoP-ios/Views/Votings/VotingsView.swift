//
//  Votings-VotingsOverview.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 08.11.24.
//

import SwiftUI
import Combine
import MeetingServiceDTOs

class ObservableArray<T: ObservableObject>: ObservableObject {
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

struct VotingsView: View {
    @StateObject private var votingService = VotingService.shared
    @StateObject private var meetingViewModel = MeetingViewModel()

    @StateObject private var votings: ObservableArray<VotingViewModel> = ObservableArray()
   @StateObject private var votingsOriginal: ObservableArray<VotingViewModel> = ObservableArray()

    @State private var searchText = ""
    @State private var selectedVoting: VotingViewModel?
    @State private var isShowingVoteSheet = false
    @State private var navigateToResultView = false
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        NavigationView {
            List {
                ForEach(groupedVotings, id: \.0) { (meetingName, votingGroup) in
                    Section(header: Text(meetingName)) {
                        ForEach(votingGroup) { voting in
                            if voting.votingDTO.startedAt != nil {
                                VotingRowView(viewModel: voting)
                                    .onTapGesture {
                                        handleVotingSelection(voting)
                                    }
                            }
                        }
                    }
                }
            }
//            .id(forceRefresh)
            .navigationTitle("Abstimmungen")
            .refreshable { await loadVotings() }
            .onAppear { Task { await loadVotings() } }
            .sheet(isPresented: $isShowingVoteSheet) {
                if let voting = selectedVoting {
                    Votings_VoteView(voting: voting.votingDTO) {
                        Task {
                            await voting.refreshAfterVote()
                        }
                        navigateToResultView = true
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToResultView) {
                if let voting = selectedVoting {
                    Votings_VotingResultView(voting: voting.votingDTO)
                }
            }
            .overlay {
                if isLoading { ProgressView("Loading...") }
                if let error = error { Text("Error: \(error)").foregroundColor(.red) }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Suchen")
            .onChange(of: searchText) { old, newValue in
               if newValue.isEmpty {
                   votings.update(items: votingsOriginal.items)
               } else {
                   votings.update(items: votingsOriginal.items.filter {
                       $0.votingDTO.question.localizedCaseInsensitiveContains(newValue)
                   })
               }
            }
        }
    }

    private func handleVotingSelection(_ voting: VotingViewModel) {
        selectedVoting = voting
        if voting.votingDTO.isOpen && !VotingStateTracker.hasVoted(for: voting.id) {
            isShowingVoteSheet = true
        } else {
            navigateToResultView = true
        }
    }

    private func loadVotings() async {
        isLoading = true
        do {
            let fetchedVotings = try await votingService.fetchVotings()
            let updatedVotings = fetchedVotings.map { dto in
                if let existing = votings.items.first(where: { $0.id == dto.id }) {
                    existing.update(votingDTO: dto)
                    return existing
                } else {
                    return VotingViewModel(voting: dto, meetingViewModel: meetingViewModel)
                }
            }
            votings.update(items: updatedVotings)
           votingsOriginal.update(items: updatedVotings)
        } catch {
            self.error = "Failed to load votings: \(error.localizedDescription)"
        }
        isLoading = false
    }


    private var groupedVotings: [(String, [VotingViewModel])] {
        let meetingsGrouped = Dictionary(grouping: votings.items, by: { $0.meeting })
        let sortedMeetingsGrouped = meetingsGrouped.sorted { lhs, rhs in
            guard let lhsMeeting = lhs.key, let rhsMeeting = rhs.key else { return false }
            return lhsMeeting.start > rhsMeeting.start
        }
        return sortedMeetingsGrouped.map { (meeting, votingGroup) in
            let sortedVotingGroup = votingGroup.sorted { lhs, rhs in
                guard let lhsStartedAt = lhs.votingDTO.startedAt, let rhsStartedAt = rhs.votingDTO.startedAt else { return false }
                return lhsStartedAt > rhsStartedAt
            }
            let meetingName = meeting?.status == .inSession
                ? "Aktuelle Sitzung (\(meeting?.name ?? "Unknown Meeting"))"
                : (meeting?.name ?? "Unknown Meeting")
            return (meetingName, sortedVotingGroup)
        }
    }
}

struct VotingRowView: View {
    @ObservedObject var viewModel: VotingViewModel

    var body: some View {
        HStack {
            Text(viewModel.votingDTO.question)
                .frame(maxWidth: .infinity, alignment: .leading)
            if !viewModel.statusSymbol.isEmpty {
                Image(systemName: viewModel.statusSymbol)
                    .foregroundColor(viewModel.symbolColor)
            }
        }
        .contentShape(Rectangle())
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

