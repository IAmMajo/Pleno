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



import SwiftUI
import MeetingServiceDTOs

struct VotingListView: View {
    // ViewModel zur Verwaltung der Abstimmungen
    @StateObject private var viewModel = VotingListViewModel()

    var body: some View {
        NavigationView {
            Group {
                // Wenn eine Abstimmung ausgewählt wurde, zeige die Detailansicht
                if let voting = viewModel.selectedVoting {
                    VotingDetailView(
                        votingId: voting.id,
                        onBack: { viewModel.selectedVoting = nil },
                        onDelete: { viewModel.deleteVoting(votingId: voting.id) },
                        onClose: { viewModel.closeVoting(votingId: voting.id) },
                        onOpen: { viewModel.openVoting(votingId: voting.id) },
                        onEdit: { editedVoting in viewModel.editVoting(editedVoting) }
                    )
                
                // Andernfalls zeige die Liste aller Abstimmungen
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
                    // Button zum Erstellen einer neuen Abstimmung
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
            .onAppear(perform: viewModel.loadVotings) // Lade Abstimmungen beim Start
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // Filter für verschiedene Abstimmungsstatus (z. B. aktiv, in Planung, abgeschlossen)
    private var filterPicker: some View {
        Picker("Filter", selection: $viewModel.filter) {
            ForEach(VotingListViewModel.VotingFilterType.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }

    // Suchleiste zur Filterung nach Abstimmungsfragen
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

    // Liste aller Abstimmungen mit Statusanzeige
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
                    // Löschen-Button für noch nicht gestartete Abstimmungen
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
