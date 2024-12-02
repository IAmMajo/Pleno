import SwiftUI
import MeetingServiceDTOs

struct VotingDetailView: View {
    let votingId: UUID
    let onBack: () -> Void
    let onDelete: () -> Void
    let onClose: () -> Void
    let onOpen: () -> Void
    let onEdit: (GetVotingDTO) -> Void

    @State private var voting: GetVotingDTO?
    @State private var votingResults: GetVotingResultsDTO?
    @State private var isLoadingVoting = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            if isLoadingVoting {
                ProgressView("Umfrage wird geladen...")
                    .padding()
            } else if let voting = voting {
                // Dynamische Auswahl der passenden View
                if voting.startedAt == nil {
                    InPlanungView(
                        voting: voting,
                        onEdit: onEdit,
                        onDelete: {
                            print("onDelete ausgelöst, kehre zur Liste zurück.") // Debugging
                            onBack() // Benutzer zur ListView zurückleiten
                        },
                        onOpen:{
                            print("onOpen ausgelöst, kehre zur Liste zurück.") // Debugging
                            onBack() // Benutzer zur ListView zurückleiten
                        },
                        onReload: loadVoting
                    )

                } else if voting.isOpen {
                    AktivView(voting: voting, votingResults: votingResults, onClose: onClose)
                } else {
                    AbgeschlossenView(voting: voting, votingResults: votingResults)
                }
            } else if let errorMessage = errorMessage {
                FehlerView(errorMessage: errorMessage, onBack: onBack)
            }
        }
        .onAppear(perform: loadVoting)
        .navigationTitle("Umfrage Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { onBack() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Zurück")
                    }
                }
            }
        }
    }

    private func loadVoting() {
        print("Lade Umfrage-Daten...") // Debugging
        isLoadingVoting = true
        errorMessage = nil

        VotingService.shared.fetchVoting(byId: votingId) { result in
            DispatchQueue.main.async {
                isLoadingVoting = false
                switch result {
                case .success(let fetchedVoting):
                    self.voting = fetchedVoting
                    if fetchedVoting.startedAt != nil {
                        print("Umfrage ist gestartet, lade Ergebnisse...") // Debugging
                        fetchVotingResults()
                    } else {
                        print("Umfrage-Daten erfolgreich geladen.") // Debugging
                    }
                case .failure(let error):
                    errorMessage = "Fehler beim Laden der Umfrage: \(error.localizedDescription)"
                    print("Fehler beim Laden der Umfrage: \(error.localizedDescription)") // Debugging
                }
            }
        }
    }


    private func fetchVotingResults() {
        VotingService.shared.fetchVotingResults(votingId: votingId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let results):
                    self.votingResults = results
                case .failure(let error):
                    print("Fehler beim Abrufen der Ergebnisse: \(error.localizedDescription)")
                }
            }
        }
    }
}
