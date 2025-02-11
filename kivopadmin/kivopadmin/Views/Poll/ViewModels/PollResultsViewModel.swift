// This file is licensed under the MIT-0 License.

import SwiftUI
import PollServiceDTOs

class PollResultsViewModel: ObservableObject {
    @Published var pollResults: GetPollResultsDTO?
    @Published var pollDetails: GetPollDTO?
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var selectedOptionIndex: UInt8?

    let pollId: UUID

    init(pollId: UUID) {
        self.pollId = pollId
        fetchPollResults()
        fetchPollDetails()
    }

    // MARK: - Lade Umfrageergebnisse
    func fetchPollResults() {
        PollAPI.shared.fetchPollResultsById(pollId: pollId) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let resultsData):
                    self.pollResults = resultsData
                case .failure(let error):
                    self.errorMessage = "Fehler beim Laden der Ergebnisse: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Lade Umfrage-Details
    func fetchPollDetails() {
        PollAPI.shared.fetchPollById(pollId: pollId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let pollData):
                    self.pollDetails = pollData
                case .failure(let error):
                    self.errorMessage = "Fehler beim Laden der Umfrage-Details: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Auswahl eines Ergebnisses togglen
    func toggleSelectedOption(_ index: UInt8) {
        selectedOptionIndex = (selectedOptionIndex == index) ? nil : index
    }

    // MARK: - Initialen aus Namen generieren
    func getInitials(from name: String) -> String {
        let nameParts = name.split(separator: " ")
        if nameParts.count == 1 {
            return String(nameParts.first!.prefix(2)).uppercased()
        }
        guard let firstInitial = nameParts.first?.prefix(1),
              let lastInitial = nameParts.last?.prefix(1) else {
            return "??"
        }
        return "\(firstInitial)\(lastInitial)".uppercased()
    }
}
