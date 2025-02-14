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

// ViewModel zur Verwaltung der Anzeige von Abstimmungsergebnissen.
class AbgeschlossenViewModel: ObservableObject {
    
    let voting: GetVotingDTO
    let votingResults: GetVotingResultsDTO?
    
    @Published var selectedOption: UInt8? = nil
    @Published var identityImages: [UUID: Data?] = [:]

    init(voting: GetVotingDTO, votingResults: GetVotingResultsDTO?) {
        self.voting = voting
        self.votingResults = votingResults
    }

    // Wechselt die Anzeige der Abstimmenden für eine Option (nur bei nicht-anonymer Abstimmung).
    func toggleSelection(for index: UInt8, identities: [GetIdentityDTO]?) {
        if !voting.anonymous {
            selectedOption = (selectedOption == index) ? nil : index
            if selectedOption != nil {
                loadIdentities(for: identities)
            }
        }
    }

    // Lädt die Profilbilder der Abstimmenden, falls noch nicht geladen.
    private func loadIdentities(for identities: [GetIdentityDTO]?) {
        guard let identities = identities else { return }

        for identity in identities where identityImages[identity.id] == nil {
            VotingService.shared.fetchProfileImage(forIdentityId: identity.id) { result in
                DispatchQueue.main.async {
                    if case .success(let data) = result {
                        self.identityImages[identity.id] = data
                    }
                }
            }
        }
    }

    // Erstellt Initialen aus einem Namen, z. B. "Max Mustermann" → "MM".
    func initials(for name: String) -> String {
        let initials = name.split(separator: " ").compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
}
