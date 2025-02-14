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
