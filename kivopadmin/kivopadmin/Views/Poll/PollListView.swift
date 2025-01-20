import SwiftUI
import PollServiceDTOs

struct PollListView: View {
    @State private var activePolls: [GetPollDTO] = []
    @State private var completedPolls: [GetPollDTO] = []
    @State private var selectedTab = 0
    @State private var showCreatePoll = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var shouldRefreshPolls = false
    @State private var showDeleteConfirmation = false
    @State private var pollToDelete: UUID?

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Umfragen", selection: $selectedTab) {
                    Text("Aktiv (\(activePolls.count))").tag(0)
                    Text("Abgeschlossen (\(completedPolls.count))").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if isLoading {
                    ProgressView("Lade Umfragen...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text("Fehler: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    if selectedTab == 0 {
                        PollListViewSection(
                            polls: activePolls,
                            deletePoll: promptDeletePoll,
                            destinationBuilder: { poll in
                                PollResultsView(pollId: poll.id)
                            },
                            dateFormatter: dateFormatter,
                            isCompleted: false
                        )
                    } else {
                        PollListViewSection(
                            polls: completedPolls,
                            deletePoll: promptDeletePoll,
                            destinationBuilder: { poll in
                                PollResultsView(pollId: poll.id)
                            },
                            dateFormatter: dateFormatter,
                            isCompleted: true
                        )
                    }
                }
            }
            .navigationTitle("Umfragen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreatePoll = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreatePoll, onDismiss: {
                if shouldRefreshPolls {
                    shouldRefreshPolls = false
                    fetchPolls()
                }
            }) {
                CreatePollView(onSave: {
                    shouldRefreshPolls = true
                    showCreatePoll = false
                })
            }
            .onAppear {
                fetchPolls()
            }
            .alert("Umfrage löschen?", isPresented: $showDeleteConfirmation) {
                Button("Abbrechen", role: .cancel) {}
                Button("Löschen", role: .destructive) {
                    if let pollId = pollToDelete {
                        deletePoll(pollId: pollId)
                    }
                }
            } message: {
                Text("Möchtest du diese Umfrage wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.")
            }
        }
    }

    private func fetchPolls() {
        isLoading = true
        errorMessage = nil
        PollAPI.shared.fetchAllPolls { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let polls):
                    print("Erfolgreich erhaltene Daten: \(polls.count) Umfragen")
                    let now = Date()
                    
                    // Aktive Umfragen: Offen und noch nicht geschlossen
                    activePolls = polls.filter { $0.isOpen && $0.closedAt > now }
                        .sorted { $0.closedAt < $1.closedAt }  // Nach Ablaufdatum aufsteigend sortieren

                    // Abgeschlossene Umfragen: Bereits geschlossen
                    completedPolls = polls.filter { !$0.isOpen || $0.closedAt <= now }
                        .sorted { $0.closedAt > $1.closedAt }  // Nach Abschlussdatum absteigend sortieren

                case .failure(let error):
                    print("Fehler beim Laden der Umfragen: \(error.localizedDescription)")
                    errorMessage = "Fehler beim Laden der Umfragen."
                }
            }
        }
    }

    private func promptDeletePoll(pollId: UUID) {
        pollToDelete = pollId
        showDeleteConfirmation = true
    }

    private func deletePoll(pollId: UUID) {
        PollAPI.shared.deletePoll(byId: pollId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    activePolls.removeAll { $0.id == pollId }
                    completedPolls.removeAll { $0.id == pollId }
                case .failure(let error):
                    errorMessage = "Fehler beim Löschen der Umfrage: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct PollListViewSection<Destination: View>: View {
    let polls: [GetPollDTO]
    let deletePoll: (UUID) -> Void
    let destinationBuilder: (GetPollDTO) -> Destination
    let dateFormatter: DateFormatter
    let isCompleted: Bool

    var body: some View {
        List {
            if polls.isEmpty {
                Text("Keine Umfragen verfügbar.")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(polls, id: \.id) { poll in
                    NavigationLink(destination: destinationBuilder(poll)) {
                        VStack(alignment: .leading) {
                            Text(poll.question)
                                .font(.headline)
                            Text(isCompleted ? "Abgeschlossen am: \(poll.closedAt, formatter: dateFormatter)" :
                                 "Endet: \(poll.closedAt, formatter: dateFormatter)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            deletePoll(poll.id)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .refreshable {
            await refreshPolls()
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    private func refreshPolls() async {
        await withCheckedContinuation { continuation in
            PollAPI.shared.fetchAllPolls { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let polls):
                        print("Erfolgreich erhaltene Daten: \(polls.count) Umfragen")
                    default:
                        break
                    }
                    continuation.resume()
                }
            }
        }
    }
}
