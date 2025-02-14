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

class InPlanungViewModel: ObservableObject {
    
    // Gibt an, ob eine Aktion (z. B. Öffnen oder Löschen) gerade ausgeführt wird
    @Published var isProcessing = false
    
    // Speichert Fehlermeldungen für die UI
    @Published var errorMessage: String?

    let voting: GetVotingDTO
    let onEdit: (GetVotingDTO) -> Void
    let onDelete: () -> Void
    let onOpen: () -> Void
    let onReload: () -> Void

    init(voting: GetVotingDTO,
         onEdit: @escaping (GetVotingDTO) -> Void,
         onDelete: @escaping () -> Void,
         onOpen: @escaping () -> Void,
         onReload: @escaping () -> Void) {
        
        self.voting = voting
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onOpen = onOpen
        self.onReload = onReload
    }

    // Öffnet eine geplante Abstimmung zur Teilnahme
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

    // Löscht eine geplante Abstimmung
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
