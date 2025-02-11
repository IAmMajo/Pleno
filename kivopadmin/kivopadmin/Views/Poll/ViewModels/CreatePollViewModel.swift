// This file is licensed under the MIT-0 License.
import SwiftUI
import PollServiceDTOs

class CreatePollViewModel: ObservableObject {
    @Published var question: String = ""
    @Published var description: String = ""
    @Published var options: [String] = [""]
    @Published var deadline: Date = Date()
    @Published var showDatePicker: Bool = false
    @Published var allowsMultipleSelections: Bool = false
    @Published var isAnonymous: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Optionen verwalten
    var validOptions: [String] {
        options.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    func addOptionIfNeeded(_ index: Int) {
        if !options[index].isEmpty && index == options.count - 1 {
            options.append("")
        }
    }

    func removeOption(at index: Int) {
        if options.count > 1 {
            options.remove(at: index)
        }
    }

    // MARK: - Umfrage erstellen
    func createPoll(onSave: @escaping () -> Void, dismiss: DismissAction) {
        isLoading = true
        errorMessage = nil

        let pollOptions = validOptions.enumerated().map { GetPollVotingOptionDTO(index: UInt8($0.offset + 1), text: $0.element) }

        let newPoll = CreatePollDTO(
            question: question.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "" : description.trimmingCharacters(in: .whitespacesAndNewlines),
            closedAt: deadline,
            anonymous: isAnonymous,
            multiSelect: allowsMultipleSelections,
            options: pollOptions
        )

        PollAPI.shared.createPoll(poll: newPoll) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    onSave()
                    dismiss()
                case .failure(let error):
                    self.errorMessage = "Fehler beim Erstellen: \(error.localizedDescription)"
                    print("❌ Fehler: \(error.localizedDescription)")
                }
            }
        }
    }
}
