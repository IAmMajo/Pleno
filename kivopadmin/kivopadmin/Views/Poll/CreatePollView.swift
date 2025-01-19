import SwiftUI
import PollServiceDTOs

struct CreatePollView: View {
    @Environment(\.dismiss) var dismiss
    @State private var question: String = ""
    @State private var description: String = ""
    @State private var options: [String] = [""]
    @State private var deadline: Date = Date()
    @State private var showDatePicker: Bool = false
    @State private var allowsMultipleSelections: Bool = false
    @State private var isAnonymous: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    let onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Allgemeine Informationen")) {
                    TextField("Frage", text: $question)
                    TextField("Beschreibung", text: $description)
                        .onChange(of: description) { oldValue, newValue in
                            if newValue.count > 300 {
                                description = String(newValue.prefix(300))
                            }
                        }
                }

                Section(header: Text("Auswahlmöglichkeiten")) {
                    ForEach(options.indices, id: \.self) { index in
                        HStack {
                            TextField("Option \(index + 1)", text: $options[index])
                                .onChange(of: options[index]) { oldValue, newValue in
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

                Section(header: Text("Optionen")) {
                    Toggle("Mehrfachauswahl erlauben", isOn: $allowsMultipleSelections)
                    Toggle("Anonymisierung aktivieren", isOn: $isAnonymous)
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
                        DatePicker(
                            "Datum und Uhrzeit",
                            selection: $deadline,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                    }
                }

                if let errorMessage = errorMessage {
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
                    Button(action: createPoll) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Erstellen")
                        }
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

    private func createPoll() {
        isLoading = true
        errorMessage = nil

        let validOptions = options.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let pollOptions = validOptions.enumerated().map { GetPollVotingOptionDTO(index: UInt8($0.offset + 1), text: $0.element) }

        let newPoll = CreatePollDTO(
            question: question.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "" : description.trimmingCharacters(in: .whitespacesAndNewlines),
            closedAt: deadline,
            anonymous: isAnonymous,
            multiSelect: allowsMultipleSelections,
            options: pollOptions
        )

        PollAPI.shared.createPoll(poll: newPoll) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    onSave()  // Signal to parent view
                    dismiss() // Ensure view is dismissed
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    print("Fehler beim Erstellen: \(error.localizedDescription)")
                }
            }
        }
    }



}
