// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs

class VotingDetailViewModel: ObservableObject {
    @Published var voting: GetVotingDTO?
    @Published var votingResults: GetVotingResultsDTO?
    @Published var isLoadingVoting = true
    @Published var errorMessage: String?

    let votingId: UUID
    let onBack: () -> Void

    init(votingId: UUID, onBack: @escaping () -> Void) {
        self.votingId = votingId
        self.onBack = onBack
        loadVoting()
    }

    func loadVoting() {
        print("🔄 Lade Abstimmung...") // Debugging
        isLoadingVoting = true
        errorMessage = nil

        VotingService.shared.fetchVoting(byId: votingId) { result in
            DispatchQueue.main.async {
                self.isLoadingVoting = false
                switch result {
                case .success(let fetchedVoting):
                    self.voting = fetchedVoting
                    if fetchedVoting.startedAt != nil {
                        print("✅ Abstimmung ist gestartet, lade Ergebnisse...") // Debugging
                        self.fetchVotingResults()
                    } else {
                        print("✅ Abstimmung erfolgreich geladen.") // Debugging
                    }
                case .failure(let error):
                    self.errorMessage = "Fehler beim Laden der Abstimmung: \(error.localizedDescription)"
                    print("❌ Fehler: \(error.localizedDescription)") // Debugging
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
                    print("❌ Fehler beim Abrufen der Ergebnisse: \(error.localizedDescription)")
                }
            }
        }
    }
}
