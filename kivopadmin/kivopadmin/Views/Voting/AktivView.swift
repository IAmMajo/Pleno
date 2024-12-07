import SwiftUI
import MeetingServiceDTOs

struct AktivView: View {
    let voting: GetVotingDTO
    let votingResults: GetVotingResultsDTO?
    let onClose: () -> Void

    @State private var isClosing = false
    @State private var errorMessage: String?

    var totalVotes: Int {
        guard let results = votingResults?.results else { return 0 }
        return results.reduce(0) { $0 + Int($1.total) }
    }

    var optionTextMap: [UInt8: String] {
        Dictionary(uniqueKeysWithValues: voting.options.map { ($0.index, $0.text) })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Frage anzeigen
                Text(voting.question)
                    .font(.title)
                    .bold()
                    .padding()

                // Beschreibung anzeigen (falls vorhanden)
                if !voting.description.isEmpty {
                    Text(voting.description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding([.leading, .trailing])
                }

                if let results = votingResults, !results.results.isEmpty {
                    // Grafische Ergebnisse (Pie Chart)
                    Text("Ergebnisse")
                        .font(.headline)
                        .padding(.top)

                    PieChartView(optionTextMap: optionTextMap, votingResults: results)
                        .frame(height: 200)
                        .padding()

                    // Tabellarische Ergebnisse
                    VStack(alignment: .leading, spacing: 8) {
                        TableView2(results: results.results, optionTextMap: optionTextMap, totalVotes: totalVotes)
                    }
                    .padding([.leading, .trailing])
                } else {
                    // Optionen in moderner Tabelle anzeigen
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Auswahlmöglichkeiten")
                            .font(.headline)
                            .padding(.bottom, 8)

                        TableView(options: voting.options)
                    }
                    .padding([.leading, .trailing])

                    Text("Keine Ergebnisse verfügbar.")
                        .foregroundColor(.gray)
                        .padding()
                }

                // Fehlermeldung anzeigen
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding()
                }

                // Umfrage abschließen
                Button(action: closeVoting) {
                    if isClosing {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    } else {
                        Label("Umfrage abschließen", systemImage: "checkmark")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .disabled(isClosing)
            }
        }
        .background(Color.white)
        .onAppear(perform: logInitialState)
    }

    private func logInitialState() {
        print("AktivView geladen für Voting-ID: \(voting.id)")
        print("Frage: \(voting.question)")
        if let results = votingResults {
            print("Ergebnisse: \(results.results)")
        } else {
            print("Keine Ergebnisse verfügbar.")
        }
    }

    private func closeVoting() {
        isClosing = true
        errorMessage = nil

        print("Anfrage zum Abschließen der Umfrage gestartet für Voting-ID: \(voting.id)")

        VotingService.shared.closeVoting(votingId: voting.id) { result in
            DispatchQueue.main.async {
                isClosing = false
                switch result {
                case .success:
                    print("Umfrage erfolgreich abgeschlossen für Voting-ID: \(voting.id)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        print("Navigiere zurück zur ListView nach Abschluss der Umfrage.")
                        onClose()
                    }
                case .failure(let error):
                    print("Fehler beim Abschließen der Umfrage: \(error.localizedDescription)")
                    self.errorMessage = "Fehler beim Abschließen der Umfrage: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Hilfskomponenten
struct TableView2: View {
    let options: [GetVotingOptionDTO]?
    let results: [GetVotingResultDTO]?
    let optionTextMap: [UInt8: String]?
    let totalVotes: Int?

    init(options: [GetVotingOptionDTO]) {
        self.options = options
        self.results = nil
        self.optionTextMap = nil
        self.totalVotes = nil
    }

    init(results: [GetVotingResultDTO], optionTextMap: [UInt8: String], totalVotes: Int) {
        self.options = nil
        self.results = results
        self.optionTextMap = optionTextMap
        self.totalVotes = totalVotes
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let options = options {
                ForEach(options, id: \.index) { option in
                    HStack {
                        Text("Option \(option.index):")
                            .font(.body)
                            .bold()
                        Text(option.text)
                            .font(.body)
                    }
                    Divider()
                }
            } else if let results = results, let optionTextMap = optionTextMap, let totalVotes = totalVotes {
                ForEach(results, id: \.index) { result in
                    HStack {
                        Text(optionTextMap[result.index] ?? "Enthaltung")
                            .font(.body)
                            .bold()
                        Spacer()
                        Text("\(result.total) Stimmen (\(percentage(for: result, totalVotes: totalVotes))%)")
                            .font(.body)
                    }
                    Divider()
                }
            }
        }
    }

    private func percentage(for result: GetVotingResultDTO, totalVotes: Int) -> String {
        guard totalVotes > 0 else { return "0" }
        let percent = Double(result.total) / Double(totalVotes) * 100
        return String(format: "%.1f", percent)
    }
}
