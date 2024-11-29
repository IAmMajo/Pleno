//
//  EditVotingView.swift
//  kivopadmin
//
//  Created by Amine Ahamri on 29.11.24.
//

import SwiftUI
import MeetingServiceDTOs


struct EditVotingView: View {
    let voting: GetVotingDTO
    @State private var question: String
    @State private var description: String
    @State private var anonymous: Bool
    @State private var options: [GetVotingOptionDTO]
    @Environment(\.presentationMode) var presentationMode
    var onSave: (GetVotingDTO) -> Void

    init(voting: GetVotingDTO, onSave: @escaping (GetVotingDTO) -> Void) {
        self.voting = voting
        self._question = State(initialValue: voting.question)
        self._description = State(initialValue: voting.description)
        self._anonymous = State(initialValue: voting.anonymous)
        self._options = State(initialValue: voting.options)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Frage")) {
                    TextField("Frage", text: $question)
                }

                Section(header: Text("Beschreibung")) {
                    TextField("Beschreibung", text: $description)
                }

                Section(header: Text("Anonym")) {
                    Toggle("Anonyme Abstimmung", isOn: $anonymous)
                }

                Section(header: Text("Optionen")) {
                    ForEach($options, id: \.index) { $option in
                        TextField("Option", text: $option.text)
                    }
                }
            }
            .navigationTitle("Bearbeiten")
            .navigationBarItems(
                leading: Button("Abbrechen") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Speichern") {
                    saveChanges()
                }
            )
        }
    }

    private func saveChanges() {
        let patchDTO = PatchVotingDTO(
            question: question,
            description: description,
            anonymous: anonymous,
            options: options
        )

        VotingService.shared.patchVoting(votingId: voting.id, patch: patchDTO) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedVoting):
                    onSave(updatedVoting)
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("Fehler beim Speichern: \(error.localizedDescription)")
                }
            }
        }
    }
}
