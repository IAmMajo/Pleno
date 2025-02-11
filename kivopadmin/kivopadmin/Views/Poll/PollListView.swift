// This file is licensed under the MIT-0 License.

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
