// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs

struct VotingListView: View {
    @StateObject private var viewModel = VotingListViewModel()

    var body: some View {
        NavigationView {
            Group {
                if let voting = viewModel.selectedVoting {
                    VotingDetailView(
                        votingId: voting.id,
                        onBack: { viewModel.selectedVoting = nil },
                        onDelete: { viewModel.deleteVoting(votingId: voting.id) },
                        onClose: { viewModel.closeVoting(votingId: voting.id) },
                        onOpen: { viewModel.openVoting(votingId: voting.id) },
                        onEdit: { editedVoting in viewModel.editVoting(editedVoting) }
                    )
                } else {
                    VStack(spacing: 10) {
                        filterPicker
                        searchBar
                        votingList
                    }
                }
            }
            .navigationTitle("Abstimmungen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showCreateVoting = true }) {
                        Label("Erstellen", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showCreateVoting) {
                CreateVotingView(
                    meetingManager: MeetingManager(),
                    onCreate: { newVoting in
                        viewModel.votings.append(newVoting)
                        viewModel.loadVotings()
                    }
                )
            }
            .alert(item: $viewModel.alertMessage) { alert in
                Alert(title: Text("Fehler"), message: Text(alert.message), dismissButton: .default(Text("OK")))
            }
            .onAppear(perform: viewModel.loadVotings)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var filterPicker: some View {
        Picker("Filter", selection: $viewModel.filter) {
            ForEach(VotingListViewModel.VotingFilterType.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }

    private var searchBar: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Nach Frage suchen", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }

    private var votingList: some View {
        List {
            ForEach(viewModel.filteredVotings, id: \.id) { voting in
                Button(action: { viewModel.selectedVoting = voting }) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(voting.question)
                            .font(.headline)
                        Text(voting.startedAt == nil ? "In Planung" : (voting.isOpen ? "Aktiv" : "Abgeschlossen"))
                            .font(.subheadline)
                            .foregroundColor(voting.startedAt == nil ? .orange : (voting.isOpen ? .green : .red))
                    }
                }
                .swipeActions {
                    if voting.startedAt == nil {
                        Button(role: .destructive) {
                            viewModel.deleteVoting(votingId: voting.id)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}
