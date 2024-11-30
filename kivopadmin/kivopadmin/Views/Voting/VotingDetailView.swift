import SwiftUI
import MeetingServiceDTOs

struct VotingDetailView: View {
    let votingId: UUID
    let onBack: () -> Void
    let onDelete: () -> Void
    let onClose: () -> Void
    let onOpen: () -> Void
    let onEdit: (GetVotingDTO) -> Void

    @State private var voting: GetVotingDTO?
    @State private var votingResults: GetVotingResultsDTO?
    @State private var isLoadingVoting = true
    @State private var isLoadingResults = false
    @State private var showEditVoting = false
    @State private var errorMessage: String?

    var totalVotes: Int {
        guard let results = votingResults?.results else { return 0 }
        return results.reduce(0) { $0 + Int($1.total) }
    }

    var optionTextMap: [UInt8: String] {
        guard let voting = voting else { return [:] }
        return Dictionary(uniqueKeysWithValues: voting.options.map { ($0.index, $0.text) })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if isLoadingVoting {
                    ProgressView("Umfrage wird geladen...")
                        .padding()
                } else if let voting = voting {
                    // Titel der Umfrage
                    Text(voting.question)
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)

                    // Optionen anzeigen
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(voting.options, id: \.index) { option in
                            HStack {
                                Text(option.text)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Spacer()
                                if let results = votingResults {
                                    let total = results.results.first { $0.index == option.index }?.total ?? 0
                                    Text("\(total) Stimmen")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .padding(.horizontal)
                    .background(Color.white)

                    // Abstimmungsergebnisse (PieChart)
                    if totalVotes > 0 {
                        Text("Abstimmungsergebnisse")
                            .font(.headline)
                            .padding(.top, 16)

                        PieChartView(optionTextMap: optionTextMap, votingResults: votingResults!)
                            .frame(height: 200)
                            .padding()
                            .background(Color.white)
                    } else {
                        Text("Noch keine Stimmen abgegeben.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                            .background(Color.white)
                    }

                    Spacer()

                    // Buttons für Aktionen
                    if voting.startedAt == nil {
                        Button(action: {
                            openVoting()
                        }) {
                            Label("Umfrage eröffnen", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }

                    Button(action: {
                        onEdit(voting)
                    }) {
                        Label("Umfrage bearbeiten", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)

                    Button(action: {
                        deleteVoting()
                    }) {
                        Label("Umfrage löschen", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                } else if let errorMessage = errorMessage {
                    Text("Fehler: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .background(Color.white)
        .navigationTitle("Umfrage Details")
        .navigationBarItems(leading: Button(action: { onBack() }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Zurück")
            }
        })
        .onAppear(perform: loadVoting)
    }


    private func openVoting() {
        VotingService.shared.openVoting(votingId: votingId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Umfrage erfolgreich eröffnet.")
                    
                    // 2 Sekunden warten, bevor die View verlassen wird
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        onOpen() // Logik zum Aktualisieren der ListView
                        onBack() // Zurück zur ListView navigieren
                    }
                    
                case .failure(let error):
                    print("Fehler beim Eröffnen der Umfrage: \(error.localizedDescription)")
                    errorMessage = "Ein Fehler ist beim Eröffnen der Umfrage aufgetreten: \(error.localizedDescription)"
                }
            }
        }
    }

    private func deleteVoting() {
        let alert = UIAlertController(
            title: "Umfrage löschen",
            message: "Möchten Sie diese Umfrage wirklich löschen?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Ja", style: .destructive, handler: { _ in
            VotingService.shared.deleteVoting(votingId: votingId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("Umfrage erfolgreich gelöscht.")
                        onDelete()
                        onBack()
                    case .failure(let error):
                        print("Fehler beim Löschen: \(error.localizedDescription)")
                        errorMessage = "Fehler beim Löschen der Umfrage."
                    }
                }
            }
        }))

        alert.addAction(UIAlertAction(title: "Nein", style: .cancel, handler: nil))

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }

    private func percentage(for result: GetVotingResultDTO) -> String {
        guard totalVotes > 0 else { return "0" }
        let percent = Double(result.total) / Double(totalVotes) * 100
        return String(format: "%.1f", percent)
    }

    private func loadVoting() {
        isLoadingVoting = true
        errorMessage = nil

        VotingService.shared.fetchVoting(byId: votingId) { result in
            DispatchQueue.main.async {
                isLoadingVoting = false
                switch result {
                case .success(let fetchedVoting):
                    self.voting = fetchedVoting
                    if fetchedVoting.startedAt != nil {
                        self.fetchVotingResults()
                    } else {
                        print("Umfrage nicht gestartet, keine Ergebnisse abrufen.")
                    }
                case .failure(let error):
                    print("Fehler beim Abrufen der Umfrage: \(error.localizedDescription)")
                    self.errorMessage = "Umfrage konnte nicht geladen werden."
                }
            }
        }
    }

    private func fetchVotingResults() {
        isLoadingResults = true
        errorMessage = nil

        VotingService.shared.fetchVotingResults(votingId: votingId) { result in
            DispatchQueue.main.async {
                isLoadingResults = false
                switch result {
                case .success(let results):
                    if results.results.isEmpty {
                        print("Keine Ergebnisse verfügbar für Voting-ID: \(votingId)")
                        self.votingResults = GetVotingResultsDTO(votingId: votingId, results: [])
                    } else {
                        self.votingResults = results
                    }
                case .failure(let error):
                    print("Fehler beim Abrufen der Ergebnisse: \(error.localizedDescription)")
                    self.errorMessage = "Ergebnisse konnten nicht geladen werden."
                    self.votingResults = nil
                }
            }
        }
    }
}
