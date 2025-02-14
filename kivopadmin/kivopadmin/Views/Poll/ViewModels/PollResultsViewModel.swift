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
