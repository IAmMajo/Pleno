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
import PollServiceDTOs

struct CreatePollView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = CreatePollViewModel()

    var onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                //Allgemeine Informationen
                Section(header: Text("Allgemeine Informationen")) {
                    TextField("Frage", text: $viewModel.question)
                    TextField("Beschreibung", text: $viewModel.description)
                        .onChange(of: viewModel.description) { _, newValue in
                            if newValue.count > 300 {
                                viewModel.description = String(newValue.prefix(300))
                            }
                        }
                }

                //Auswahlmöglichkeiten
                Section(header: Text("Auswahlmöglichkeiten")) {
                    ForEach(Array(viewModel.options.enumerated()), id: \.offset) { index, _ in
                        HStack {
                            TextField("Option \(index + 1)", text: $viewModel.options[index])
                                .onChange(of: viewModel.options[index]) { _, _ in
                                    viewModel.addOptionIfNeeded(index)
                                }
                            if viewModel.options.count > 1 {
                                Button(action: { viewModel.removeOption(at: index) }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }

                //Optionen
                Section(header: Text("Optionen")) {
                    Toggle("Mehrfachauswahl erlauben", isOn: $viewModel.allowsMultipleSelections)
                    Toggle("Anonyme Umfrage", isOn: $viewModel.isAnonymous)
                }

                //Abschlusszeit
                Section(header: Text("Abschlusszeit")) {
                    HStack {
                        Text("Ende:")
                        Spacer()
                        Button(action: {
                            withAnimation { viewModel.showDatePicker.toggle() }
                        }) {
                            HStack {
                                Text(viewModel.deadline, style: .date)
                                Text(viewModel.deadline, style: .time)
                            }
                            .padding(8)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    
                    // DatePicker wird animiert eingeblendet
                    if viewModel.showDatePicker {
                        DatePicker(
                            "Datum und Uhrzeit",
                            selection: $viewModel.deadline,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .transition(.opacity)
                    }
                }

                //Fehlermeldung
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Umfrage erstellen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.createPoll(onSave: onSave, dismiss: dismiss) }) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Erstellen")
                        }
                    }
                    .disabled(viewModel.question.isEmpty || viewModel.validOptions.count < 2)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
    }
}
