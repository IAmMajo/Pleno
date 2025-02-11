// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs

struct VotingDetailView: View {
    // ViewModel zur Verwaltung der Abstimmungsdetails
    @StateObject private var viewModel: VotingDetailViewModel

    // Callbacks für verschiedene Aktionen (z. B. Löschen, Schließen, Öffnen, Bearbeiten)
    let onDelete: () -> Void
    let onClose: () -> Void
    let onOpen: () -> Void
    let onEdit: (GetVotingDTO) -> Void

    // Initialisiert die View mit einer Abstimmungs-ID und den benötigten Funktionen
    init(votingId: UUID, onBack: @escaping () -> Void, onDelete: @escaping () -> Void, onClose: @escaping () -> Void, onOpen: @escaping () -> Void, onEdit: @escaping (GetVotingDTO) -> Void) {
        _viewModel = StateObject(wrappedValue: VotingDetailViewModel(votingId: votingId, onBack: onBack))
        self.onDelete = onDelete
        self.onClose = onClose
        self.onOpen = onOpen
        self.onEdit = onEdit
    }

    var body: some View {
        VStack(spacing: 0) {
            // Ladeanzeige während die Abstimmung abgerufen wird
            if viewModel.isLoadingVoting {
                ProgressView("Abstimmung wird geladen...")
                    .padding()
            
            // Wenn die Abstimmung erfolgreich geladen wurde
            } else if let voting = viewModel.voting {
                
                // Falls die Abstimmung noch nicht gestartet wurde, wird die "InPlanungView" angezeigt
                if voting.startedAt == nil {
                    InPlanungView(
                        voting: voting,
                        onEdit: onEdit,
                        onDelete: {
                            print("🛑 onDelete ausgelöst, kehre zur Liste zurück.")
                            viewModel.onBack()
                        },
                        onOpen: {
                            print("🟢 onOpen ausgelöst, kehre zur Liste zurück.")
                            viewModel.onBack()
                        },
                        onReload: viewModel.loadVoting
                    )
                
                // Falls die Abstimmung gerade läuft, wird die "AktivView" angezeigt
                } else if voting.isOpen {
                    AktivView(
                        voting: voting,
                        onBack: {
                            print("⬅️ Zurück zur Voting-Liste.")
                            viewModel.onBack()
                        }
                    )
                
                // Falls die Abstimmung beendet ist, wird die "AbgeschlossenView" mit den Ergebnissen angezeigt
                } else {
                    AbgeschlossenView(voting: voting, votingResults: viewModel.votingResults)
                }
            
            // Falls ein Fehler beim Laden der Abstimmung auftritt, wird eine Fehleransicht angezeigt
            } else if let errorMessage = viewModel.errorMessage {
                FehlerView(errorMessage: errorMessage, onBack: viewModel.onBack)
            }
        }
        .navigationTitle("Details zur Abstimmung")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { viewModel.onBack() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Zurück")
                    }
                }
            }
        }
    }
}
