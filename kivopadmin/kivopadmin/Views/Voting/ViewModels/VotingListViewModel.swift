// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs

class VotingListViewModel: ObservableObject {
    @Published var votings: [GetVotingDTO] = []
    @Published var selectedVoting: GetVotingDTO? = nil
    @Published var showCreateVoting = false
    @Published var filter: VotingFilterType = .active
    @Published var searchText: String = ""
    @Published var alertMessage: AlertMessage?
    
    private let votingService = VotingService.shared

    enum VotingFilterType: String, CaseIterable {
        case planning = "In Planung"
        case active = "Aktiv"
        case inactive = "Abgeschlossen"
    }

    struct AlertMessage: Identifiable {
        let id = UUID()
        let message: String
    }

    init() {
        loadVotings()
    }

    var filteredVotings: [GetVotingDTO] {
        let filtered: [GetVotingDTO]
        switch filter {
        case .planning:
            filtered = votings.filter { $0.startedAt == nil }
        case .active:
            filtered = votings.filter { $0.isOpen }
        case .inactive:
            filtered = votings.filter { !$0.isOpen && $0.startedAt != nil }
        }

        return filtered.sorted {
            let date0 = $0.closedAt ?? $0.startedAt ?? Date.distantPast
            let date1 = $1.closedAt ?? $1.startedAt ?? Date.distantPast
            return date0 > date1
        }
    }

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

    func closeVoting(votingId: UUID) {
        votingService.closeVoting(votingId: votingId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.loadVotings()
                case .failure(let error):
                    self.alertMessage = AlertMessage(message: "Fehler beim Schließen: \(error.localizedDescription)")
                }
            }
        }
    }

    func openVoting(votingId: UUID) {
        votingService.openVoting(votingId: votingId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.loadVotings()
                case .failure(let error):
                    self.alertMessage = AlertMessage(message: "Fehler beim Öffnen: \(error.localizedDescription)")
                }
            }
        }
    }

    func editVoting(_ editedVoting: GetVotingDTO) {
        if let index = votings.firstIndex(where: { $0.id == editedVoting.id }) {
            votings[index] = editedVoting
        }
    }
}
