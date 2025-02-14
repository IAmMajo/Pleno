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
