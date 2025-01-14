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
                                    stimmen: poll.votes.map { $0.value }
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


struct CreatePollView: View {
    @Environment(\.dismiss) var dismiss
    @State private var question: String = ""
    @State private var description: String = ""
    @State private var options: [String] = [""]
    @State private var deadline: Date = Date()
    let onPollCreated: (Poll) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Allgemeine Informationen")) {
                    TextField("Frage", text: $question)
                    TextField("Beschreibung", text: $description)
                        .onChange(of: description) { _ in
                            if description.count > 300 {
                                description = String(description.prefix(300))
                            }
                        }
                }

                Section(header: Text("Auswahlmöglichkeiten")) {
                    ForEach(options.indices, id: \ .self) { index in
                        HStack {
                            TextField("Option \(index + 1)", text: $options[index])
                                .onChange(of: options[index]) { newValue in
                                    if !newValue.isEmpty && index == options.count - 1 {
                                        options.append("")
                                    }
                                }
                            if options.count > 1 {
                                Button(action: {
                                    options.remove(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Abschlusszeit")) {
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                }
            }
            .navigationTitle("Umfrage erstellen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Erstellen") {
                        guard options.filter({ !$0.isEmpty }).count >= 2 else {
                            return
                        }
                        let newPoll = Poll(
                            id: UUID(),
                            question: question,
                            description: description,
                            options: options.filter { !$0.isEmpty },
                            votes: [:],
                            deadline: deadline,
                            isActive: true
                        )
                        onPollCreated(newPoll)
                        dismiss()
                    }
                    .disabled(question.isEmpty || options.filter({ !$0.isEmpty }).count < 2)
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
