// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs

struct VotingDetailView: View {
    @StateObject private var viewModel: VotingDetailViewModel

    let onDelete: () -> Void
    let onClose: () -> Void
    let onOpen: () -> Void
    let onEdit: (GetVotingDTO) -> Void

    init(votingId: UUID, onBack: @escaping () -> Void, onDelete: @escaping () -> Void, onClose: @escaping () -> Void, onOpen: @escaping () -> Void, onEdit: @escaping (GetVotingDTO) -> Void) {
        _viewModel = StateObject(wrappedValue: VotingDetailViewModel(votingId: votingId, onBack: onBack))
        self.onDelete = onDelete
        self.onClose = onClose
        self.onOpen = onOpen
        self.onEdit = onEdit
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoadingVoting {
                ProgressView("Abstimmung wird geladen...")
                    .padding()
            } else if let voting = viewModel.voting {
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
                } else if voting.isOpen {
                    AktivView(
                        voting: voting,
                        onBack: {
                            print("⬅️ Zurück zur Voting-Liste.")
                            viewModel.onBack()
                        }
                    )
                } else {
                    AbgeschlossenView(voting: voting, votingResults: viewModel.votingResults)
                }
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
