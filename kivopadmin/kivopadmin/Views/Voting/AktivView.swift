import SwiftUI
import MeetingServiceDTOs

struct AktivView: View {
    let voting: GetVotingDTO // Voting-Daten direkt einbinden
    let onBack: () -> Void // Callback für die Rücknavigation

    @StateObject private var webSocketService = WebSocketService()
    @State private var isClosing = false
    @State private var value: Int = 0
    @State private var total: Int = 0
    @State private var progress: Double = 0
    @State private var showParticipationQuestion = false // Flag für Frage nach Teilnahme
    @State private var errorMessageReplaced = false // Flag für benutzerfreundliche Nachricht

    var body: some View {
        VStack {
            if webSocketService.liveStatus != nil {
                VStack {
                    ZStack {
                        Circle()
                            .stroke(
                                Color.blue.opacity(0.3),
                                lineWidth: 35
                            )
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                Color.blue,
                                style: StrokeStyle(
                                    lineWidth: 35,
                                    lineCap: .round
                                )
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.easeOut(duration: 0.8), value: progress)
                        Text("\(value)/\(total)")
                            .font(.system(size: 50))
                            .fontWeight(.bold)
                            .foregroundColor(Color.blue)
                    }
                    .padding(30)

                    Text(votingProgressText)
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            } else if let errorMessage = webSocketService.errorMessage, !errorMessageReplaced {
                if showParticipationQuestion {
                    VStack {
                        Spacer()
                        Text("Haben Sie selbst schon an der Umfrage teilgenommen?")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            onBack()
                        }
                    }
                } else {
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(2)
                            .padding()
                        Text("Lade Daten...")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showParticipationQuestion = true
                        }
                    }
                }
            } else {
                // Ladeanzeige
                VStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(2)
                    Text("Warte auf Echtzeit-Daten...")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                }
            }

            Spacer()

            // Voting-Details
            VStack(alignment: .leading, spacing: 10) {
                Text(voting.question)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)

                if !voting.description.isEmpty {
                    Text(voting.description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding()
            .cornerRadius(10)
            .padding([.leading, .trailing])

            Spacer()

            // Umfrage beenden Button
            Button(action: closeVoting) {
                if isClosing {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                } else {
                    Text("Umfrage beenden")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .disabled(isClosing)
        }
        .onAppear {
            print("Verbinde mit Voting ID: \(voting.id)")
            webSocketService.connect(to: voting.id)
        }
        .onDisappear {
            print("Trenne WebSocket-Verbindung für Voting ID: \(voting.id)")
            webSocketService.disconnect()
        }
        .onChange(of: webSocketService.liveStatus) { _, newLiveStatus in
            guard let newLiveStatus = newLiveStatus else { return }
            updateProgress(liveStatus: newLiveStatus)
        }
    }

    private var votingProgressText: String {
        if value == 0 {
            return "Noch keine Stimmen abgegeben."
        } else if value == 1 {
            return "Es hat \(value) von \(total) Personen abgestimmt."
        } else if value < total {
            return "Es haben \(value) von \(total) Personen abgestimmt."
        } else {
            return "Alle \(total) Personen haben abgestimmt."
        }
    }

    private func updateProgress(liveStatus: String) {
        print("Empfangener Live-Status: \(liveStatus)")
        let parts = liveStatus.split(separator: "/")
        if let currentValue = Int(parts.first ?? ""), let totalValue = Int(parts.last ?? "") {
            self.value = currentValue
            self.total = totalValue
            withAnimation(.easeOut(duration: 0.8)) {
                self.progress = Double(currentValue) / Double(totalValue)
            }
        }
    }

    private func closeVoting() {
        guard !isClosing else {
            print("Warnung: closeVoting bereits in Bearbeitung.")
            return
        }

        isClosing = true

        print("Sende Anfrage zum Beenden der Umfrage mit ID: \(voting.id)")

        VotingService.shared.closeVoting(votingId: voting.id) { result in
            DispatchQueue.main.async {
                self.isClosing = false
                switch result {
                case .success:
                    print("Umfrage erfolgreich abgeschlossen: \(self.voting.id)")
                    webSocketService.disconnect() // Beende die WebSocket-Verbindung
                    onBack() // Automatische Rückkehr zur Voting-Liste
                case .failure(let error):
                    print("Fehler beim Abschließen: \(error)")
                }
            }
        }
    }
}
