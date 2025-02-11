// This file is licensed under the MIT-0 License.
import SwiftUI
import MeetingServiceDTOs

class EditVotingViewModel: ObservableObject {
    @Published var question: String
    @Published var description: String
    @Published var options: [String]
    @Published var anonymous: Bool
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let votingId: UUID
    private let onReload: () -> Void
    private let onSave: (GetVotingDTO) -> Void

    init(voting: GetVotingDTO, onReload: @escaping () -> Void, onSave: @escaping (GetVotingDTO) -> Void) {
        self.votingId = voting.id
        self.onReload = onReload
        self.onSave = onSave
        self.question = voting.question
        self.description = voting.description
        self.options = voting.options.map { $0.text }
        self.anonymous = voting.anonymous

        if options.isEmpty || options.last?.trimmingCharacters(in: .whitespaces).isEmpty == false {
            options.append("")
        }
    }

    func saveChanges(dismiss: DismissAction) {
        isSaving = true
        errorMessage = nil

        let filteredOptions = options.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        let patchVoting = PatchVotingDTO(
            question: question,
            description: description.isEmpty ? nil : description,
            anonymous: anonymous,
            options: filteredOptions.enumerated().map { index, text in
                GetVotingOptionDTO(index: UInt8(index + 1), text: text)
            }
        )

        VotingService.shared.patchVoting(votingId: votingId, patch: patchVoting) { result in
            DispatchQueue.main.async {
                self.isSaving = false
                switch result {
                case .success:
                    let updatedVoting = GetVotingDTO(
                        id: self.votingId,
                        meetingId: UUID(), // Beispiel, falls `meetingId` benötigt wird
                        question: self.question,
                        description: self.description,
                        isOpen: false,
                        startedAt: nil,
                        closedAt: nil,
                        anonymous: self.anonymous,
                        iVoted: false,
                        options: filteredOptions.enumerated().map { index, text in
                            GetVotingOptionDTO(index: UInt8(index + 1), text: text)
                        }
                    )
                    self.onSave(updatedVoting)
                    dismiss()
                case .failure(let error):
                    self.errorMessage = "Fehler beim Speichern der Abstimmung: \(error.localizedDescription)"
                }
            }
        }
    }

    func isFormValid() -> Bool {
        !question.isEmpty && options.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    func handleOptionChange(index: Int, newValue: String) {
        let trimmedValue = newValue.trimmingCharacters(in: .whitespaces)

        if !trimmedValue.isEmpty && index == options.count - 1 {
            options.append("")
        }

        if options.count > 1 {
            options = options.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty || options.last == "" }
        }
    }

    func removeOption(at index: Int) {
        if options.count > 1 {
            options.remove(at: index)
        }
    }
}
