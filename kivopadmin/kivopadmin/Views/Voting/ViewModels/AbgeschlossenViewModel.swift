// This file is licensed under the MIT-0 License.

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
