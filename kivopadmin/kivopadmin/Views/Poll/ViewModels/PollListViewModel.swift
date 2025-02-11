// This file is licensed under the MIT-0 License.
import SwiftUI
import PollServiceDTOs

class PollListViewModel: ObservableObject {
    @Published var activePolls: [GetPollDTO] = []
    @Published var completedPolls: [GetPollDTO] = []
    @Published var selectedTab = 0
    @Published var showCreatePoll = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showDeleteConfirmation = false
    @Published var pollToDelete: UUID?

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }

    init() {
        fetchPolls()
    }

    func fetchPolls() {
        isLoading = true
        errorMessage = nil
        PollAPI.shared.fetchAllPolls { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let polls):
                    print("✅ \(polls.count) Umfragen erhalten")
                    let now = Date()

                    // Aktive Umfragen: Offen & noch nicht abgelaufen
                    self.activePolls = polls.filter { $0.isOpen && $0.closedAt > now }
                        .sorted { $0.closedAt < $1.closedAt } 

                    // Abgeschlossene Umfragen
                    self.completedPolls = polls.filter { !$0.isOpen || $0.closedAt <= now }
                        .sorted { $0.closedAt > $1.closedAt } 

                case .failure(let error):
                    print("❌ Fehler beim Laden: \(error.localizedDescription)")
                    self.errorMessage = "Fehler beim Laden der Umfragen."
                }
            }
        }
    }

    func promptDeletePoll(pollId: UUID) {
        pollToDelete = pollId
        showDeleteConfirmation = true
    }

    func deletePoll() {
        guard let pollId = pollToDelete else { return }
        PollAPI.shared.deletePoll(byId: pollId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.activePolls.removeAll { $0.id == pollId }
                    self.completedPolls.removeAll { $0.id == pollId }
                    self.showDeleteConfirmation = false
                case .failure(let error):
                    self.errorMessage = "Fehler beim Löschen: \(error.localizedDescription)"
                }
            }
        }
    }
}
