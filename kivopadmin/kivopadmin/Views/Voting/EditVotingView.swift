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
                Section(header: Text("Frage")) {
                    TextField("Frage eingeben", text: $question)
                        .textFieldStyle(DefaultTextFieldStyle())
                }

                Section(header: Text("Beschreibung")) {
                    TextField("Beschreibung eingeben", text: $description)
                        .textFieldStyle(DefaultTextFieldStyle())
                }

                Section(header: Text("Optionen")) {
                    ForEach($options.indices, id: \.self) { index in
                        HStack {
                            TextField("Option \(index + 1)", text: $options[index])
                                .textFieldStyle(DefaultTextFieldStyle())

                            // Löschen-Button nur für leere Felder
                            if options[index].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Button(action: {
                                    options.remove(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        options.remove(atOffsets: indexSet)
                    }

                    Button("Option hinzufügen") {
                        options.append("")
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
            .navigationTitle("Umfrage bearbeiten")
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

        // Leere Optionen entfernen
        let filteredOptions = options.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        // Daten vorbereiten
        let patchVoting = PatchVotingDTO(
            question: question,
            description: description.isEmpty ? nil : description,
            anonymous: voting.anonymous,
            options: filteredOptions.enumerated().map { index, text in
                GetVotingOptionDTO(index: UInt8(index + 1), text: text)
            }
        )

        // Backend-Aufruf
        VotingService.shared.patchVoting(votingId: voting.id, patch: patchVoting) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    print("Umfrage erfolgreich bearbeitet.")
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
                    onSave(updatedVoting) // Änderungen weitergeben
                    dismiss() // View schließen
                case .failure(let error):
                    errorMessage = "Fehler beim Speichern der Umfrage: \(error.localizedDescription)"
                }
            }
        }
    }

    private func isFormValid() -> Bool {
        !question.isEmpty && options.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}
