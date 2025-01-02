import Foundation
import SwiftUI
import MeetingServiceDTOs

class CreateVotingViewModel: ObservableObject {
    @Published var question: String = ""
    @Published var description: String = ""
    @Published var anonymous: Bool = false
    @Published var options: [String] = [""]
    @Published var selectedMeetingId: UUID?
    @Published var meetings: [GetMeetingDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false

    private let meetingManager = MeetingManager()

    func fetchMeetings() {
        isLoading = true
        meetingManager.fetchAllMeetings()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.meetings = self.meetingManager.meetings
            self.selectedMeetingId = self.meetings.first?.id
            self.isLoading = false
        }
    }

    func createVoting(completion: @escaping (Result<GetVotingDTO, Error>) -> Void) {
        guard let meetingId = selectedMeetingId else {
            showError(message: "Bitte wählen Sie ein Meeting aus.")
            completion(.failure(NSError(domain: "MeetingSelection", code: 1, userInfo: nil)))
            return
        }

        let validOptions = options.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !question.isEmpty, !validOptions.isEmpty else {
            showError(message: "Bitte füllen Sie alle Felder korrekt aus.")
            completion(.failure(NSError(domain: "ValidationError", code: 2, userInfo: nil)))
            return
        }

        let optionDTOs = validOptions.enumerated().map { GetVotingOptionDTO(index: UInt8($0.offset), text: $0.element) }
        let newVoting = CreateVotingDTO(
            meetingId: meetingId,
            question: question.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description,
            anonymous: anonymous,
            options: optionDTOs
        )

        VotingService.shared.createVoting(voting: newVoting) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func isFormValid() -> Bool {
        !question.trimmingCharacters(in: .whitespaces).isEmpty &&
        !options.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.isEmpty &&
        selectedMeetingId != nil
    }

    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
