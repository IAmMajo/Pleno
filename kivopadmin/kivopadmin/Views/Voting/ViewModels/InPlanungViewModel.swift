// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs

class InPlanungViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var errorMessage: String?

    let voting: GetVotingDTO
    let onEdit: (GetVotingDTO) -> Void
    let onDelete: () -> Void
    let onOpen: () -> Void
    let onReload: () -> Void

    init(voting: GetVotingDTO, onEdit: @escaping (GetVotingDTO) -> Void, onDelete: @escaping () -> Void, onOpen: @escaping () -> Void, onReload: @escaping () -> Void) {
        self.voting = voting
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onOpen = onOpen
        self.onReload = onReload
    }

    func openVoting() {
        guard !isProcessing else {
            print("⚠️ Warnung: openVoting bereits in Bearbeitung.")
            return
        }

        isProcessing = true
        errorMessage = nil

        VotingService.shared.openVoting(votingId: voting.id) { result in
            DispatchQueue.main.async {
                self.isProcessing = false
                switch result {
                case .success:
                    print("✅ Abstimmung erfolgreich eröffnet: \(self.voting.id)")
                    self.onOpen()
                case .failure(let error):
                    self.errorMessage = "Fehler beim Öffnen der Abstimmung: \(error.localizedDescription)"
                    print("❌ Fehler beim Öffnen: \(error)")
                }
            }
        }
    }

    func deleteVoting() {
        guard !isProcessing else {
            print("⚠️ Warnung: deleteVoting bereits in Bearbeitung.")
            return
        }

        isProcessing = true
        errorMessage = nil

        VotingService.shared.deleteVoting(votingId: voting.id) { result in
            DispatchQueue.main.async {
                self.isProcessing = false
                switch result {
                case .success:
                    print("✅ Abstimmung erfolgreich gelöscht: \(self.voting.id)")
                    self.onDelete()
                case .failure(let error):
                    self.errorMessage = "Fehler beim Löschen der Abstimmung: \(error.localizedDescription)"
                    print("❌ Fehler beim Löschen: \(error)")
                }
            }
        }
    }
}
