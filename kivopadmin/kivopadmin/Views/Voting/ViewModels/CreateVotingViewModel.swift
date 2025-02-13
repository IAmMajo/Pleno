// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs

class CreateVotingViewModel: ObservableObject {
    @Published var question: String = ""
    @Published var description: String = ""
    @Published var anonymous: Bool = false
    @Published var options: [String] = [""]
    @Published var selectedMeetingId: UUID? = nil
    @Published var errorMessage: String?

    // Speichert die geladenen Sitzungen
    @Published var meetings: [GetMeetingDTO] = []
    @Published var isLoaded: Bool = false

    let meetingManager: MeetingManager
    let onCreate: (GetVotingDTO) -> Void

    init(meetingManager: MeetingManager, onCreate: @escaping (GetVotingDTO) -> Void) {
        self.meetingManager = meetingManager
        self.onCreate = onCreate
        fetchMeetings()
    }

    func fetchMeetings() {
        isLoaded = false  //Warten, bis Sitzungen fertig geladen sind
        meetingManager.fetchAllMeetings()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.meetings = self.meetingManager.meetings
            self.isLoaded = true  // Sitzungen sind geladen
            print("[DEBUG] Meetings geladen: \(self.meetings.count)")
        }
    }

    func selectedMeetingName() -> String {
        if let meeting = meetings.first(where: { $0.id == selectedMeetingId }) {
            return meeting.name
        }
        return "Sitzung auswählen"
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
