import SwiftUI
import MeetingServiceDTOs

struct EditVotingView: View {
    @Environment(\.dismiss) private var dismiss
    @State var voting: GetVotingDTO
    let onReload: () -> Void
    let onSave: (GetVotingDTO) -> Void

    @State private var question = ""
    @State private var description = ""
    @State private var options: [String] = []
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                // Frage
                Section(header: Text("Frage")) {
                    TextField("Frage eingeben", text: $question)
                        .autocapitalization(.sentences)
                }

                // Beschreibung
                Section(header: Text("Beschreibung")) {
                    TextField("Beschreibung eingeben", text: $description)
                        .autocapitalization(.sentences)
                }

                // Optionen
                Section(header: Text("Optionen")) {
                    ForEach($options.indices, id: \.self) { index in
                        HStack {
                            TextField("Option \(index + 1)", text: $options[index])
                            
                            if options.count > 1 {
                                Button(action: {
                                    options.remove(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    Button(action: { options.append("") }) {
                        Label("Option hinzufügen", systemImage: "plus")
                    }
                }

                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Abstimmung bearbeiten")
            .navigationBarItems(
                leading: Button("Abbrechen") {
                    dismiss()
                },
                trailing: Button(action: saveChanges) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Speichern")
                    }
                }
                .disabled(!isFormValid() || isSaving)
            )
            .onAppear(perform: populateFields)
        }
    }

    private func populateFields() {
        question = voting.question
        description = voting.description
        options = voting.options.map { $0.text }
    }

    private func saveChanges() {
        isSaving = true
        errorMessage = nil

        let filteredOptions = options.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        let patchVoting = PatchVotingDTO(
            question: question,
            description: description.isEmpty ? nil : description,
            anonymous: voting.anonymous,
            options: filteredOptions.enumerated().map { index, text in
                GetVotingOptionDTO(index: UInt8(index + 1), text: text)
            }
        )

        VotingService.shared.patchVoting(votingId: voting.id, patch: patchVoting) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    print("Abstimmung erfolgreich bearbeitet.")
                    let updatedVoting = GetVotingDTO(
                        id: voting.id,
                        meetingId: voting.meetingId,
                        question: question,
                        description: description,
                        isOpen: voting.isOpen,
                        startedAt: voting.startedAt,
                        closedAt: voting.closedAt,
                        anonymous: voting.anonymous,
                        options: filteredOptions.enumerated().map { index, text in
                            GetVotingOptionDTO(index: UInt8(index + 1), text: text)
                        }
                    )
                    onSave(updatedVoting)
                    dismiss()
                case .failure(let error):
                    errorMessage = "Fehler beim Speichern der Abstimmung: \(error.localizedDescription)"
                }
            }
        }
    }

    private func isFormValid() -> Bool {
        !question.isEmpty && options.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}
