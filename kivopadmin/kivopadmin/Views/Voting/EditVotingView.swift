// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



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
