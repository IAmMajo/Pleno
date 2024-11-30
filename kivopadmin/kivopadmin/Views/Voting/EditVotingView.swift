//
//  EditVotingView.swift
//  kivopadmin
//
//  Created by Amine Ahamri on 29.11.24.
//

import SwiftUI
import MeetingServiceDTOs

struct EditVotingView: View {
    @Environment(\.dismiss) private var dismiss // Um die Ansicht zu schließen
    @State var voting: GetVotingDTO
    let onSave: (GetVotingDTO) -> Void

    @State private var question = ""
    @State private var description = ""
    @State private var options: [String] = []

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
            }
            .navigationTitle("Umfrage bearbeiten")
            .navigationBarItems(
                leading: Button("Abbrechen") {
                    dismiss() // Ansicht schließen
                },
                trailing: Button("Speichern") {
                    saveChanges()
                    dismiss() // Änderungen speichern und Ansicht schließen
                }
                .disabled(!isFormValid())
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
        // Prüfen, ob der Index bei 1 beginnen soll
        let optionDTOs = options.enumerated().map { index, text in
            GetVotingOptionDTO(index: UInt8(index + 1), text: text) // Offset von 1 hinzugefügt
        }

        let updatedVoting = GetVotingDTO(
            id: voting.id,
            meetingId: voting.meetingId,
            question: question,
            description: description,
            isOpen: voting.isOpen,
            anonymous: voting.anonymous,
            options: optionDTOs
        )

        // Debugging: Gesendete Daten anzeigen
        print("Gespeicherte Änderungen:")
        print("Frage: \(updatedVoting.question)")
        print("Beschreibung: \(updatedVoting.description ?? "Keine Beschreibung")")
        print("Optionen: \(updatedVoting.options)")

        onSave(updatedVoting)
    }


    private func isFormValid() -> Bool {
        !question.isEmpty && !options.contains { $0.isEmpty }
    }
}
