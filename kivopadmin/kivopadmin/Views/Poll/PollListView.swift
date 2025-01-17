import SwiftUI

struct PollListView: View {
    @State private var activePolls: [Poll] = []
    @State private var completedPolls: [Poll] = []
    @State private var selectedTab = 0
    @State private var showCreatePoll = false

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
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

                if selectedTab == 0 {
                    PollListViewSection(
                        polls: activePolls,
                        destinationBuilder: { poll in
                            PollDetailView(poll: poll, onPollEnd: { updatedPoll in
                                moveToCompleted(poll: updatedPoll)
                            })
                        },
                        dateFormatter: dateFormatter,
                        isCompleted: false
                    )
                } else {
                    PollListViewSection(
                        polls: completedPolls,
                        destinationBuilder: { poll in
                            PollResultsView(
                                    frage: poll.question,
                                    optionen: poll.options,
                                    stimmen: poll.votes.values.flatMap { $0 }
                                )                        },
                        dateFormatter: dateFormatter,
                        isCompleted: true
                    )
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
            .sheet(isPresented: $showCreatePoll) {
                CreatePollView(onPollCreated: { newPoll in
                    activePolls.append(newPoll)
                })
            }
        }
    }

    private func moveToCompleted(poll: Poll) {
        if let index = activePolls.firstIndex(where: { $0.id == poll.id }) {
            var updatedPoll = poll
            updatedPoll.isActive = false
            completedPolls.append(updatedPoll)
            activePolls.remove(at: index)
        }
    }
}

struct PollListViewSection<Destination: View>: View {
    let polls: [Poll]
    let destinationBuilder: (Poll) -> Destination
    let dateFormatter: DateFormatter
    let isCompleted: Bool

    var body: some View {
        List {
            ForEach(polls) { poll in
                NavigationLink(destination: destinationBuilder(poll)) {
                    VStack(alignment: .leading) {
                        Text(poll.question)
                            .font(.headline)
                        Text(isCompleted ? "Abgeschlossen am: \(poll.deadline, formatter: dateFormatter)" : "Endet: \(poll.deadline, formatter: dateFormatter)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}


