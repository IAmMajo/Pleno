// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs

struct EditVotingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditVotingViewModel

    init(voting: GetVotingDTO, onReload: @escaping () -> Void, onSave: @escaping (GetVotingDTO) -> Void) {
        _viewModel = StateObject(wrappedValue: EditVotingViewModel(voting: voting, onReload: onReload, onSave: onSave))
    }

    var body: some View {
        NavigationView {
            Form {
                // Frage
                Section(header: Text("Frage")) {
                    TextField("Frage eingeben", text: $viewModel.question)
                        .autocapitalization(.sentences)
                }

                // Beschreibung
                Section(header: Text("Beschreibung")) {
                    TextField("Beschreibung eingeben", text: $viewModel.description)
                        .autocapitalization(.sentences)
                }

                // Anonyme Abstimmung
                Section(header: Text("Anonym")) {
                    Toggle("Anonyme Abstimmung", isOn: $viewModel.anonymous)
                }

                // Optionen
                Section(header: Text("Optionen")) {
                    ForEach(viewModel.options.indices, id: \.self) { index in
                        HStack {
                            TextField("Option \(index + 1)", text: $viewModel.options[index])
                                .onChange(of: viewModel.options[index]) { _, newValue in
                                    viewModel.handleOptionChange(index: index, newValue: newValue)
                                }

                            if viewModel.options.count > 1 && index != 0 {
                                Button(action: {
                                    viewModel.removeOption(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
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
                trailing: Button(action: {
                    viewModel.saveChanges(dismiss: dismiss)
                }) {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Text("Speichern")
                    }
                }
                .disabled(!viewModel.isFormValid() || viewModel.isSaving)
            )
        }
    }
}
