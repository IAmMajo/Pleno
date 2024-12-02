//
//  AktivView.swift
//  kivopadmin
//
//  Created by Amine Ahamri on 01.12.24.
//

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
                    .font(.title2)
                    .padding()

                // Ergebnisse und Auswahlmöglichkeiten anzeigen
                if let results = votingResults {
                    if results.results.isEmpty {
                        Text("Keine Abstimmungsergebnisse verfügbar.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        // PieChart für Ergebnisse
                        PieChartView(optionTextMap: optionTextMap, votingResults: results)
                            .frame(height: 200)
                            .padding()

                        // Detaillierte Ergebnisse anzeigen
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(results.results, id: \.index) { result in
                                HStack {
                                    Text(optionTextMap[result.index] ?? "Unbekannt")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(result.total) Stimmen (\(percentage(for: result))%)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    // Wenn keine Ergebnisse vorhanden sind
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(voting.options, id: \.index) { option in
                            Text("• \(option.text)")
                                .font(.headline)
                                .padding(.vertical, 4)
                        }
                    }
                    .padding()

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

    private func percentage(for result: GetVotingResultDTO) -> String {
        guard totalVotes > 0 else { return "0" }
        let percent = Double(result.total) / Double(totalVotes) * 100
        return String(format: "%.1f", percent)
    }
}
