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
    
    // Umfrage löschen
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
