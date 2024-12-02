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
                }

                Section(header: Text("Beschreibung")) {
                    TextField("Beschreibung eingeben", text: $description)
                }

                Section(header: Text("Optionen")) {
                    ForEach($options.indices, id: \.self) { index in
                        TextField("Option \(index + 1)", text: $options[index])
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

        // Daten vorbereiten
        let patchVoting = PatchVotingDTO(
            question: question,
            description: description.isEmpty ? nil : description,
            anonymous: voting.anonymous,
            options: options.enumerated().map { index, text in
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
                    dismiss() // Schließt die `EditVotingView`
                    onReload() // Signalisiert der `InPlanungView`, die Ansicht neu zu laden
                case .failure(let error):
                    errorMessage = "Fehler beim Speichern der Umfrage: \(error.localizedDescription)"
                }
            }
        }
    }

    private func isFormValid() -> Bool {
        !question.isEmpty && !options.contains { $0.isEmpty }
    }
}
