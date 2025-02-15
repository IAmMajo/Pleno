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

class VotingListViewModel: ObservableObject {
    
    // Liste aller geladenen Abstimmungen
    @Published var votings: [GetVotingDTO] = []
    
    // Aktuell ausgewählte Abstimmung
    @Published var selectedVoting: GetVotingDTO? = nil
    
    // Steuert die Anzeige des Erstellungsdialogs für eine neue Abstimmung
    @Published var showCreateVoting = false
    
    // Filter für die Abstimmungen (z. B. aktiv, in Planung, abgeschlossen)
    @Published var filter: VotingFilterType = .active
    
    // Suchtext für die Filterung der Abstimmungen
    @Published var searchText: String = ""
    
    // Speichert eine mögliche Fehlermeldung für Alerts
    @Published var alertMessage: AlertMessage?
    
    private let votingService = VotingService.shared

    // Definiert die verschiedenen Filteroptionen für Abstimmungen
    enum VotingFilterType: String, CaseIterable {
        case planning = "In Planung"
        case active = "Aktiv"
        case inactive = "Abgeschlossen"
    }

    // Struktur zur Darstellung von Fehlermeldungen
    struct AlertMessage: Identifiable {
        let id = UUID()
        let message: String
    }

    init() {
        loadVotings()
    }

    // Gibt die gefilterte Liste von Abstimmungen zurück
    var filteredVotings: [GetVotingDTO] {
        let filtered: [GetVotingDTO]
        
        switch filter {
        case .planning:
            // Filtert alle Abstimmungen, die noch nicht gestartet wurden
            filtered = votings.filter { $0.startedAt == nil }
        case .active:
            // Filtert alle offenen Abstimmungen
            filtered = votings.filter { $0.isOpen }
        case .inactive:
            // Filtert alle abgeschlossenen Abstimmungen
            filtered = votings.filter { !$0.isOpen && $0.startedAt != nil }
        }

        // Sortiert nach dem letzten Änderungsdatum (geschlossen oder gestartet)
        return filtered.sorted {
            let date0 = $0.closedAt ?? $0.startedAt ?? Date.distantPast
            let date1 = $1.closedAt ?? $1.startedAt ?? Date.distantPast
            return date0 > date1
        }
    }

    // Lädt die Liste aller Abstimmungen aus dem Backend
    func loadVotings() {
        votingService.fetchVotings { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedVotings):
                    self.votings = fetchedVotings
                case .failure(let error):
                    self.alertMessage = AlertMessage(message: "Fehler beim Laden: \(error.localizedDescription)")
                }
            }
        }
    }

    // Löscht eine Abstimmung anhand der ID
    func deleteVoting(votingId: UUID) {
        votingService.deleteVoting(votingId: votingId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.votings.removeAll { $0.id == votingId }
                case .failure(let error):
                    self.alertMessage = AlertMessage(message: "Fehler beim Löschen: \(error.localizedDescription)")
                }
            }
        }
    }

    // Schließt eine aktive Abstimmung
    func closeVoting(votingId: UUID) {
        votingService.closeVoting(votingId: votingId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.loadVotings() // Aktualisiert die Liste nach erfolgreichem Schließen
                case .failure(let error):
                    self.alertMessage = AlertMessage(message: "Fehler beim Schließen: \(error.localizedDescription)")
                }
            }
        }
    }

    // Öffnet eine geplante Abstimmung zur aktiven Abstimmung
    func openVoting(votingId: UUID) {
        votingService.openVoting(votingId: votingId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.loadVotings() // Aktualisiert die Liste nach erfolgreichem Öffnen
                case .failure(let error):
                    self.alertMessage = AlertMessage(message: "Fehler beim Öffnen: \(error.localizedDescription)")
                }
            }
        }
    }

    // Aktualisiert eine bestehende Abstimmung in der Liste
    func editVoting(_ editedVoting: GetVotingDTO) {
        if let index = votings.firstIndex(where: { $0.id == editedVoting.id }) {
            votings[index] = editedVoting
        }
    }
}
