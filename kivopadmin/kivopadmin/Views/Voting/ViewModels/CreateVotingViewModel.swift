// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs

class CreateVotingViewModel: ObservableObject {
    
    // Speichert die eingegebene Frage für die Abstimmung
    @Published var question: String = ""
    
    // Optionale Beschreibung der Abstimmung
    @Published var description: String = ""
    
    // Gibt an, ob die Abstimmung anonym sein soll
    @Published var anonymous: Bool = false
    
    // Liste der Abstimmungsoptionen, beginnt mit einem leeren Eintrag
    @Published var options: [String] = [""]
    
    // Speichert die ID des ausgewählten Meetings
    @Published var selectedMeetingId: UUID? = nil
    
    // Enthält eine Fehlermeldung, falls etwas schiefgeht
    @Published var errorMessage: String?
    
    let meetingManager: MeetingManager
    let onCreate: (GetVotingDTO) -> Void
    
    init(meetingManager: MeetingManager, onCreate: @escaping (GetVotingDTO) -> Void) {
        self.meetingManager = meetingManager
        self.onCreate = onCreate
        fetchMeetings()
    }

    // Lädt alle verfügbaren Meetings
    func fetchMeetings() {
        meetingManager.fetchAllMeetings()
    }

    // Gibt den Namen des ausgewählten Meetings zurück oder eine Standardnachricht
    func selectedMeetingName() -> String {
        if let meeting = meetingManager.meetings.first(where: { $0.id == selectedMeetingId }) {
            return meeting.name
        }
        return "Meeting auswählen"
    }

    // Prüft, ob das Formular gültig ist (Frage vorhanden, mindestens eine gültige Option, Meeting ausgewählt)
    func isFormValid() -> Bool {
        !question.trimmingCharacters(in: .whitespaces).isEmpty &&
        !options.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.isEmpty &&
        selectedMeetingId != nil
    }

    // Fügt eine neue Option hinzu, wenn die letzte Option nicht leer ist, und entfernt überflüssige leere Felder
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

    // Erstellt eine neue Abstimmung und sendet sie an den Server
    func createVoting(dismiss: DismissAction) {
        guard let selectedMeetingId = selectedMeetingId else {
            errorMessage = "Kein Meeting ausgewählt"
            return
        }

        let validOptions = options.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let optionDTOs = validOptions.enumerated().map { GetVotingOptionDTO(index: UInt8($0.offset + 1), text: $0.element) }

        let newVoting = CreateVotingDTO(
            meetingId: selectedMeetingId,
            question: question.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description,
            anonymous: anonymous,
            options: optionDTOs
        )

        // Sendet die Abstimmung an den Server und verarbeitet das Ergebnis
        VotingService.shared.createVoting(voting: newVoting) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let createdVoting):
                    self.onCreate(createdVoting)
                    dismiss()
                case .failure(let error):
                    self.errorMessage = "Fehler beim Erstellen: \(error.localizedDescription)"
                }
            }
        }
    }
}
