// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs

class AbgeschlossenViewModel: ObservableObject {
    let voting: GetVotingDTO
    let votingResults: GetVotingResultsDTO?
    
    @Published var selectedOption: UInt8? = nil
    @Published var identityImages: [UUID: Data?] = [:]

    init(voting: GetVotingDTO, votingResults: GetVotingResultsDTO?) {
        self.voting = voting
        self.votingResults = votingResults
    }

    func toggleSelection(for index: UInt8, identities: [GetIdentityDTO]?) {
        if !voting.anonymous {
            if selectedOption == index {
                selectedOption = nil
            } else {
                selectedOption = index
                loadIdentities(for: identities)
            }
        }
    }

    func loadIdentities(for identities: [GetIdentityDTO]?) {
        guard let identities = identities else { return }

        for identity in identities {
            if identityImages[identity.id] == nil {
                VotingService.shared.fetchProfileImage(forIdentityId: identity.id) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let data):
                            self.identityImages[identity.id] = data
                        case .failure(let error):
                            print("Fehler beim Abrufen des Profilbilds: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    func initials(for name: String) -> String {
        let components = name.split(separator: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
}
