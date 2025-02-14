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
    @State private var activePolls: [GetPollDTO] = []
    @State private var completedPolls: [GetPollDTO] = []
    @State private var selectedTab = 0
    @State private var showCreatePoll = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var shouldRefreshPolls = false

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Umfragen", selection: $selectedTab) {
                    Text("Aktiv").tag(0)
                    Text("Abgeschlossen").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if isLoading {
                    ProgressView("Lade Umfragen...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text("Fehler: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    if selectedTab == 0 {
                        PollListViewSection(
                            polls: activePolls,
                            destinationBuilder: { poll in
                                poll.iVoted ? AnyView(PollResultsView(pollId: poll.id)) : AnyView(PollDetailView(poll: poll))
                            },
                            dateFormatter: dateFormatter,
                            isCompleted: false
                        )
                    } else {
                        PollListViewSection(
                            polls: completedPolls,
                            destinationBuilder: { poll in
                                PollResultsView(pollId: poll.id)
                            },
                            dateFormatter: dateFormatter,
                            isCompleted: true
                        )
                    }
                }
            }
            .navigationTitle("Umfragen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreatePoll = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreatePoll, onDismiss: {
                if shouldRefreshPolls {
                    shouldRefreshPolls = false
                    fetchPolls()
                }
            }) {
                CreatePollView(onSave: {
                    shouldRefreshPolls = true
                    showCreatePoll = false
                })
            }
            .onAppear {
                fetchPolls()
            }
        }
    }

    private func fetchPolls() {
        isLoading = true
        errorMessage = nil
        PollAPI.shared.fetchAllPolls { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let polls):
                    print("Erfolgreich erhaltene Daten: \(polls.count) Umfragen")
                    let now = Date()

                    // Aktive Umfragen: Noch offene Umfragen
                    activePolls = polls.filter { $0.isOpen && $0.closedAt > now }
                        .sorted { $0.closedAt < $1.closedAt }

                    // Abgeschlossene Umfragen: Geschlossen oder abgelaufen
                    completedPolls = polls.filter { !$0.isOpen || $0.closedAt <= now }
                        .sorted { $0.closedAt > $1.closedAt }

                case .failure(let error):
                    print("Fehler beim Laden der Umfragen: \(error.localizedDescription)")
                    errorMessage = "Fehler beim Laden der Umfragen."
                }
            }
        }
    }
}

struct PollListViewSection<Destination: View>: View {
    let polls: [GetPollDTO]
    let destinationBuilder: (GetPollDTO) -> Destination
    let dateFormatter: DateFormatter
    let isCompleted: Bool

    var body: some View {
        List {
            if polls.isEmpty {
                Text("Keine Umfragen verfügbar.")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(polls, id: \.id) { poll in
                    NavigationLink(destination: destinationBuilder(poll)) {
                        VStack(alignment: .leading) {
                            Text(poll.question)
                                .font(.headline)
                            Text(isCompleted ? "Abgeschlossen am: \(poll.closedAt, formatter: dateFormatter)" :
                                 "Endet: \(poll.closedAt, formatter: dateFormatter)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .refreshable {
            await refreshPolls()
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    private func refreshPolls() async {
        await withCheckedContinuation { continuation in
            PollAPI.shared.fetchAllPolls { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let polls):
                        print("Erfolgreich erhaltene Daten: \(polls.count) Umfragen")
                    default:
                        break
                    }
                    continuation.resume()
                }
            }
        }
    }
}
