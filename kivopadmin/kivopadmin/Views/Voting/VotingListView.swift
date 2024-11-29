import SwiftUI
import MeetingServiceDTOs

struct VotingListView: View {
    @StateObject private var votingService = VotingService.shared
    @State private var selectedVoting: GetVotingDTO?
    @State private var showCreateVoting = false
    @State private var filter: FilterType = .active
    @State private var searchText: String = ""
    @State private var alertMessage: AlertMessage?

    let meetingId: UUID = UUID()

    enum FilterType: String, CaseIterable {
        case active = "Aktiv"
        case inactive = "Abgeschlossen"
    }

    struct AlertMessage: Identifiable {
        let id = UUID()
        let message: String
    }

    var filteredVotings: [GetVotingDTO] {
        let votingsByStatus = votingService.votings.filter { filter == .active ? $0.isOpen : !$0.isOpen }
        if searchText.isEmpty {
            return votingsByStatus
        } else {
            return votingsByStatus.filter { $0.question.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            Group {
                if let voting = selectedVoting {
                    VotingDetailView(
                        voting: voting,
                        onBack: { selectedVoting = nil },
                        onDelete: { deleteVoting(votingId: voting.id) },
                        onClose: { closeVoting(votingId: voting.id) }
                    )
                } else {
                    VStack(spacing: 10) {
                        filterPicker
                        searchBar
                        votingList
                    }
                }
            }
            .navigationTitle("Umfragen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateVoting = true }) {
                        Label("Erstellen", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateVoting) {
                CreateVotingView(
                    meetingManager: MeetingManager(), // Falls ein MeetingManager erforderlich ist
                    onCreate: { newVoting in
                        votingService.votings.append(newVoting)
                    }
                )
            }

            .alert(item: $alertMessage) { alert in
                Alert(title: Text("Fehler"), message: Text(alert.message), dismissButton: .default(Text("OK")))
            }
            .onAppear(perform: loadVotings)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var filterPicker: some View {
        Picker("Filter", selection: $filter) {
            ForEach(FilterType.allCases, id: \.self) { filter in
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
                TextField("Nach Frage suchen", text: $searchText)
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
            ForEach(filteredVotings, id: \.id) { voting in
                Button(action: { selectedVoting = voting }) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(voting.question)
                            .font(.headline)
                            .foregroundColor(.black)
                        Text(voting.isOpen ? "Aktiv" : "Abgeschlossen")
                            .font(.subheadline)
                            .foregroundColor(voting.isOpen ? .green : .red)
                    }
                }
                .listRowBackground(Color.white)
                .swipeActions {
                    if voting.startedAt == nil {
                        Button(role: .destructive) {
                            deleteVoting(votingId: voting.id)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }

    private func loadVotings() {
        votingService.fetchVotings { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let votings):
                    votingService.votings = votings
                case .failure(let error):
                    alertMessage = AlertMessage(message: "Fehler beim Laden der Umfragen: \(error.localizedDescription)")
                }
            }
        }
    }

    private func deleteVoting(votingId: UUID) {
        votingService.deleteVoting(votingId: votingId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    votingService.votings.removeAll { $0.id == votingId }
                case .failure(let error):
                    alertMessage = AlertMessage(message: "Fehler beim Löschen: \(error.localizedDescription)")
                }
            }
        }
    }

    private func closeVoting(votingId: UUID) {
        votingService.closeVoting(votingId: votingId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    loadVotings()
                case .failure(let error):
                    alertMessage = AlertMessage(message: "Fehler beim Schließen: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct VotingListView_Previews: PreviewProvider {
    static var previews: some View {
        VotingListView()
    }
}
