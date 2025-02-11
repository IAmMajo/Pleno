// This file is licensed under the MIT-0 License.
import SwiftUI
import PollServiceDTOs

struct PollListView: View {
    @StateObject private var viewModel = PollListViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Umfragen", selection: $viewModel.selectedTab) {
                    Text("Aktiv (\(viewModel.activePolls.count))").tag(0)
                    Text("Abgeschlossen (\(viewModel.completedPolls.count))").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if viewModel.isLoading {
                    ProgressView("Lade Umfragen...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    if viewModel.selectedTab == 0 {
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showCreatePoll = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showCreatePoll, onDismiss: {
                viewModel.fetchPolls()
            }) {
                CreatePollView(onSave: {
                    viewModel.showCreatePoll = false
                    viewModel.fetchPolls()
                })
            }
            .onAppear {
                viewModel.fetchPolls()
            }
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
