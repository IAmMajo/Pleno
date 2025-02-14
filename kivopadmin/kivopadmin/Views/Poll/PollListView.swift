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

struct PollListView: View {
    // ViewModel zur Verwaltung der Umfragen
    @StateObject private var viewModel = PollListViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                // Segmented Picker zur Auswahl zwischen aktiven und abgeschlossenen Umfragen
                Picker("Umfragen", selection: $viewModel.selectedTab) {
                    Text("Aktiv (\(viewModel.activePolls.count))").tag(0)
                    Text("Abgeschlossen (\(viewModel.completedPolls.count))").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Ladeanzeige, falls die Daten noch abgerufen werden
                if viewModel.isLoading {
                    ProgressView("Lade Umfragen...")
                        .padding()
                }
                // Fehlermeldung anzeigen, falls ein Fehler auftritt
                else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                // Anzeige der Umfragen basierend auf der gewählten Kategorie
                else {
                    if viewModel.selectedTab == 0 {
                        // Aktive Umfragen anzeigen
                        PollListViewSection(
                            polls: viewModel.activePolls,
                            deletePoll: viewModel.promptDeletePoll,
                            destinationBuilder: { poll in
                                PollResultsView(pollId: poll.id)
                            },
                            dateFormatter: viewModel.dateFormatter,
                            isCompleted: false
                        )
                    } else {
                        // Abgeschlossene Umfragen anzeigen
                        PollListViewSection(
                            polls: viewModel.completedPolls,
                            deletePoll: viewModel.promptDeletePoll,
                            destinationBuilder: { poll in
                                PollResultsView(pollId: poll.id)
                            },
                            dateFormatter: viewModel.dateFormatter,
                            isCompleted: true
                        )
                    }
                }
            }
            .navigationTitle("Umfragen")
            .toolbar {
                // Button zum Erstellen einer neuen Umfrage
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showCreatePoll = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // Modal-Ansicht für das Erstellen einer neuen Umfrage
            .sheet(isPresented: $viewModel.showCreatePoll, onDismiss: {
                viewModel.fetchPolls()
            }) {
                CreatePollView(onSave: {
                    viewModel.showCreatePoll = false
                    viewModel.fetchPolls()
                })
            }
            // Umfragen abrufen, sobald die Ansicht erscheint
            .onAppear {
                viewModel.fetchPolls()
            }
            // Bestätigungsdialog zum Löschen einer Umfrage
            .alert("Umfrage löschen?", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Abbrechen", role: .cancel) {}
                Button("Löschen", role: .destructive) {
                    viewModel.deletePoll()
                }
            } message: {
                Text("Möchtest du diese Umfrage wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.")
            }
        }
    }
}
