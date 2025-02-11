// This file is licensed under the MIT-0 License.
import SwiftUI
import MeetingServiceDTOs

class EditVotingViewModel: ObservableObject {
    
    // Speichert die Frage der Abstimmung
    @Published var question: String
    
    // Optionale Beschreibung der Abstimmung
    @Published var description: String
    
    // Liste der Abstimmungsoptionen
    @Published var options: [String]
    
    // Gibt an, ob die Abstimmung anonym ist
    @Published var anonymous: Bool
    
    // Gibt an, ob die Änderungen gespeichert werden
    @Published var isSaving = false
    
    // Speichert mögliche Fehlermeldungen
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

        // Fügt automatisch ein leeres Feld hinzu, falls das letzte Feld nicht leer ist
        if options.isEmpty || options.last?.trimmingCharacters(in: .whitespaces).isEmpty == false {
            options.append("")
        }
    }

    func saveChanges(dismiss: DismissAction) {
        isSaving = true
        errorMessage = nil

        // Filtert nur gültige Optionen heraus
        let filteredOptions = options.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        let patchVoting = PatchVotingDTO(
            question: question,
            description: description.isEmpty ? nil : description,
            anonymous: anonymous,
            options: filteredOptions.enumerated().map { index, text in
                GetVotingOptionDTO(index: UInt8(index + 1), text: text)
            }
        )

        // Sendet die Änderungen an den Server
        VotingService.shared.patchVoting(votingId: votingId, patch: patchVoting) { result in
            DispatchQueue.main.async {
                self.isSaving = false
                switch result {
                case .success:
                    let updatedVoting = GetVotingDTO(
                        id: self.votingId,
                        meetingId: UUID(),
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

    // Prüft, ob das Formular gültig ist (Frage vorhanden und mindestens eine gültige Option)
    func isFormValid() -> Bool {
        !question.isEmpty && options.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    // Fügt neue Optionen hinzu, wenn nötig, und entfernt überflüssige leere Felder
    func handleOptionChange(index: Int, newValue: String) {
        let trimmedValue = newValue.trimmingCharacters(in: .whitespaces)

        if !trimmedValue.isEmpty && index == options.count - 1 {
            options.append("")
        }

        if options.count > 1 {
            options = options.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty || options.last == "" }
        }
    }

    // Entfernt eine Option aus der Liste, falls mindestens eine Option übrig bleibt
    func removeOption(at index: Int) {
        if options.count > 1 {
            options.remove(at: index)
        }
    }
}
