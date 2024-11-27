import SwiftUI

struct CreateVotingView: View {
    @Binding var votings: [Voting]
    @State private var title = ""
    @State private var options = [String]()
    @State private var newOptions = [String]([""]) // Initialisiere mit einem leeren Eingabefeld
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Titel")) {
                        TextField("Titel der Umfrage", text: $title)
                    }
                    Section(header: Text("Optionen")) {
                        ForEach(newOptions.indices, id: \.self) { index in
                            HStack {
                                TextField("Option \(index + 1)", text: Binding(
                                    get: { newOptions[index] },
                                    set: { newValue in
                                        newOptions[index] = newValue
                                        // Automatisch ein neues Feld hinzufügen, wenn das aktuelle nicht leer ist
                                        if !newValue.trimmingCharacters(in: .whitespaces).isEmpty && index == newOptions.count - 1 {
                                            newOptions.append("")
                                        }
                                    }
                                ))
                            }
                        }
                    }
                }
                Button(action: createVoting) {
                    Text("Umfrage erstellen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Neue Umfrage")
        }
    }

    private func createVoting() {
        // Bereinige die Optionen und füge sie zur Liste hinzu
        let validOptions = newOptions
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        // Neue Umfrage erstellen, nur wenn Titel und Optionen vorhanden sind
        guard !title.isEmpty, !validOptions.isEmpty else { return }

        let newVoting = Voting(
            id: UUID(),
            title: title,
            options: validOptions,
            results: Array(repeating: 0, count: validOptions.count),
            isOpen: true,
            createdAt: Date()
        )
        votings.append(newVoting)

        // Pop-up schließen
        dismiss()
    }
}
