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
    
    let meetingManager: MeetingManager
    let onCreate: (GetVotingDTO) -> Void
    
    init(meetingManager: MeetingManager, onCreate: @escaping (GetVotingDTO) -> Void) {
        self.meetingManager = meetingManager
        self.onCreate = onCreate
        fetchMeetings()
    }

    func fetchMeetings() {
        meetingManager.fetchAllMeetings()
    }

    func selectedMeetingName() -> String {
        if let meeting = meetingManager.meetings.first(where: { $0.id == selectedMeetingId }) {
            return meeting.name
        }
        return "Meeting auswählen"
    }

    func isFormValid() -> Bool {
        !question.trimmingCharacters(in: .whitespaces).isEmpty &&
        !options.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.isEmpty &&
        selectedMeetingId != nil
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
