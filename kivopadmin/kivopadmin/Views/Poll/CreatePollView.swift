import SwiftUI

struct CreatePollView: View {
    @Environment(\.dismiss) var dismiss
    @State private var question: String = ""
    @State private var description: String = ""
    @State private var options: [String] = [""]
    @State private var deadline: Date = Date()
    @State private var showDatePicker: Bool = false
    @State private var allowsMultipleSelections: Bool = false
    let onPollCreated: (Poll) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Allgemeine Informationen")) {
                    TextField("Frage", text: $question)
                    TextField("Beschreibung", text: $description)
                        .onChange(of: description) { newValue in
                            if newValue.count > 300 {
                                description = String(newValue.prefix(300))
                            }
                        }
                }

                Section(header: Text("Auswahlmöglichkeiten")) {
                    ForEach(options.indices, id: \.self) { index in
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

                Section(header: Text("Mehrfachauswahl")) {
                    Toggle("Mehrfachauswahl erlauben", isOn: $allowsMultipleSelections)
                }

                Section(header: Text("Abschlusszeit")) {
                    HStack {
                        Text("Ende:")
                        Spacer()
                        Button(action: {
                            withAnimation {
                                showDatePicker.toggle()
                            }
                        }) {
                            HStack {
                                Text(deadline, style: .date)
                                Text(deadline, style: .time)
                            }
                            .padding(8)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                        }
                    }

                    if showDatePicker {
                        VStack {
                            DatePicker(
                                "Datum und Uhrzeit",
                                selection: $deadline,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                        }
                    }
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
                            isActive: true,
                            allowsMultipleSelections: allowsMultipleSelections
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
