// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs

class VotingDetailViewModel: ObservableObject {
    
    // Speichert die geladene Abstimmung
    @Published var voting: GetVotingDTO?
    
    // Speichert die Ergebnisse der Abstimmung, falls sie gestartet wurde
    @Published var votingResults: GetVotingResultsDTO?
    
    // Gibt an, ob die Abstimmung gerade geladen wird
    @Published var isLoadingVoting = true
    
    // Speichert eine mögliche Fehlermeldung
    @Published var errorMessage: String?

    let votingId: UUID
    let onBack: () -> Void

    init(votingId: UUID, onBack: @escaping () -> Void) {
        self.votingId = votingId
        self.onBack = onBack
        loadVoting()
    }

    // Lädt die Details der Abstimmung aus dem Backend
    func loadVoting() {
        print("🔄 Lade Abstimmung...") // Debugging-Information
        isLoadingVoting = true
        errorMessage = nil

        VotingService.shared.fetchVoting(byId: votingId) { result in
            DispatchQueue.main.async {
                self.isLoadingVoting = false
                switch result {
                case .success(let fetchedVoting):
                    self.voting = fetchedVoting
                    
                    // Falls die Abstimmung bereits gestartet wurde, lade die Ergebnisse
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

    // Ruft die Ergebnisse der Abstimmung ab, falls sie bereits läuft
    private func fetchVotingResults() {
        VotingService.shared.fetchVotingResults(votingId: votingId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let results):
                    self.votingResults = results
                case .failure(let error):
                    print("❌ Fehler beim Abrufen der Ergebnisse: \(error.localizedDescription)") // Debugging
                }
            }
        }
    }
}
