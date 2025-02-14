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

struct InPlanungView: View {
    @StateObject private var viewModel: InPlanungViewModel
    @State private var showEditPopup = false

    init(voting: GetVotingDTO, onEdit: @escaping (GetVotingDTO) -> Void, onDelete: @escaping () -> Void, onOpen: @escaping () -> Void, onReload: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: InPlanungViewModel(voting: voting, onEdit: onEdit, onDelete: onDelete, onOpen: onOpen, onReload: onReload))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Frage anzeigen
                Text(viewModel.voting.question)
                    .font(.title)
                    .bold()
                    .padding()

                // Beschreibung anzeigen (falls vorhanden)
                if !viewModel.voting.description.isEmpty {
                    Text(viewModel.voting.description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding([.leading, .trailing])
                }

                // Tabelle für Auswahlmöglichkeiten
                VStack(alignment: .leading, spacing: 8) {
                    Text("Auswahlmöglichkeiten")
                        .font(.headline)
                        .padding(.bottom, 8)

                    TableView(options: viewModel.voting.options)
                }
                .padding([.leading, .trailing])

                // Fehlermeldung anzeigen
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding()
                }

                // Buttons
                actionButton(title: "Abstimmung eröffnen", icon: "play.fill", color: .green, action: viewModel.openVoting)
                actionButton(title: "Abstimmung bearbeiten", icon: "pencil", color: .blue) {
                    showEditPopup = true
                }
                actionButton(title: "Abstimmung löschen", icon: "trash", color: .red, action: viewModel.deleteVoting)
            }
        }
        .background(Color.white)
        .sheet(isPresented: $showEditPopup) {
            EditVotingView(
                voting: viewModel.voting,
                onReload: {
                    viewModel.onReload() // Reload-Funktion weitergeben
                },
                onSave: { updatedVoting in
                    showEditPopup = false
                    viewModel.onEdit(updatedVoting) // Update-Funktion aufrufen
                    viewModel.onReload() // Daten nach Bearbeitung neu laden
                    viewModel.onDelete()
                }
            )
        }
    }

    // MARK: - Buttons
    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            if viewModel.isProcessing {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            } else {
                Label(title, systemImage: icon)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(color)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .disabled(viewModel.isProcessing)
    }
}

// MARK: - TableView Component
struct TableView: View {
    let options: [GetVotingOptionDTO]

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(options, id: \.index) { option in
                HStack {
                    Text("Option \(option.index):")
                        .font(.body)
                        .bold()
                    Text(option.text)
                        .font(.body)
                }
                .padding(.vertical, 4)
                Divider()
            }
        }
    }
}
