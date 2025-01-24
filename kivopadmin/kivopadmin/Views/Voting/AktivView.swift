import SwiftUI
import MeetingServiceDTOs

struct AktivView: View {
    let voting: GetVotingDTO
    let onBack: () -> Void

    @StateObject private var webSocketService = WebSocketService()
    @State private var isClosing = false
    @State private var value: Int = 0
    @State private var total: Int = 0
    @State private var progress: Double = 0
    @State private var showParticipationMessage = false
    @State private var errorMessageDisplayed = false

    var body: some View {
        VStack {
            if voting.iVoted {
                if webSocketService.liveStatus != nil {
                    votingProgressView
                } else if let errorMessage = webSocketService.errorMessage, !errorMessageDisplayed {
                    errorView(errorMessage: errorMessage)
                } else {
                    loadingView
                }
            } else {
                participationWarningView
            }

            Spacer()

            votingDetailsView

            Spacer()

            closeVotingButton
        }
        .onAppear {
            if voting.iVoted {
                print("Verbinde mit Voting ID: \(voting.id)")
                webSocketService.connect(to: voting.id)
            }
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

    private var votingProgressView: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 35)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 35, lineCap: .round))
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
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(2)
                .padding()
            Text("Warte auf Echtzeit-Daten...")
                .foregroundColor(.gray)
                .padding()
            Spacer()
        }
    }

    private func errorView(errorMessage: String) -> some View {
        VStack {
            Spacer()
            Text("Fehler beim Laden der Daten: \(errorMessage)")
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
    }

    private var participationWarningView: some View {
        VStack {
            Spacer()
            Text("Sie müssen zuerst an der Umfrage teilnehmen, um den Live-Stand zu sehen.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding()
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                onBack()
            }
        }
    }

    private var votingDetailsView: some View {
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
    }

    private var closeVotingButton: some View {
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
                    webSocketService.disconnect()
                    onBack()
                case .failure(let error):
                    print("Fehler beim Abschließen: \(error)")
                }
            }
        }
    }
}
