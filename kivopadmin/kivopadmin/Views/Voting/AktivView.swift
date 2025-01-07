import SwiftUI
import MeetingServiceDTOs

struct AktivView: View {
    let voting: GetVotingDTO
    let onBack: () -> Void

    @StateObject private var webSocketManager: WebSocketManager
    @State private var isClosing = false
    @State private var errorMessage: String?

    init(voting: GetVotingDTO, onBack: @escaping () -> Void) {
        self.voting = voting
        self.onBack = onBack
        _webSocketManager = StateObject(wrappedValue: WebSocketManager(url: URL(string: "wss://kivop.ipv64.net/meetings/votings/\(voting.id)/live-status")!))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Frage und Beschreibung anzeigen
                Text(voting.question)
                    .font(.title)
                    .bold()
                    .padding()

                if !voting.description.isEmpty {
                    Text(voting.description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding([.leading, .trailing])
                }

                // Echtzeit-Ergebnisse anzeigen
                if let results = webSocketManager.liveResults {
                    Text("Echtzeit-Ergebnisse")
                        .font(.headline)
                        .padding(.top)

                    PieChartView(optionTextMap: optionTextMap, votingResults: results)
                        .frame(height: 200)
                        .padding()

                    TableView2(results: results.results, optionTextMap: optionTextMap, totalVotes: totalVotes(results: results.results))
                        .padding([.leading, .trailing])
                } else {
                    Text("Warte auf Echtzeit-Daten...")
                        .foregroundColor(.gray)
                        .padding()
                }

                // Fehler anzeigen
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding()
                }

                // Umfrage abschließen
                actionButton(title: "Umfrage abschließen", icon: "checkmark", color: .orange, action: closeVoting)
            }
        }
        .onDisappear {
            webSocketManager.disconnect()
        }
    }

    private var optionTextMap: [UInt8: String] {
        Dictionary(uniqueKeysWithValues: voting.options.map { ($0.index, $0.text) })
    }

    private func totalVotes(results: [GetVotingResultDTO]?) -> Int {
        guard let results = results else { return 0 }
        return results.reduce(0) { $0 + Int($1.total) }
    }

    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            if isClosing {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            } else {
                Label(title, systemImage: icon)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(color)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .disabled(isClosing)
    }

    private func closeVoting() {
        guard !isClosing else {
            print("Warnung: closeVoting bereits in Bearbeitung.")
            return
        }

        isClosing = true
        errorMessage = nil

        VotingService.shared.closeVoting(votingId: voting.id) { result in
            DispatchQueue.main.async {
                self.isClosing = false
                switch result {
                case .success:
                    print("Umfrage erfolgreich abgeschlossen: \(self.voting.id)")
                    onBack() // Zurück zur Voting-Liste navigieren
                case .failure(let error):
                    self.errorMessage = "Fehler beim Abschließen der Umfrage: \(error.localizedDescription)"
                    print("Fehler beim Abschließen: \(error)")
                }
            }
        }
    }
}

struct TableView2: View {
    let results: [GetVotingResultDTO]?
    let optionTextMap: [UInt8: String]?
    let totalVotes: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let results = results, let optionTextMap = optionTextMap, let totalVotes = totalVotes {
                ForEach(results, id: \ .index) { result in
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

