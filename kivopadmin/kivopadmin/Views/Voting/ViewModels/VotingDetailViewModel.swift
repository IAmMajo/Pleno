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
