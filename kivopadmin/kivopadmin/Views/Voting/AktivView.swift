import SwiftUI
import MeetingServiceDTOs

struct AktivView: View {
    let voting: GetVotingDTO // Voting-Daten direkt einbinden
    let onBack: () -> Void // Callback für die Rücknavigation
    
    @StateObject private var webSocketService = WebSocketService()
    @State private var value: Int = 0
    @State private var total: Int = 0
    @State private var progress: Double = 0
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            // Fortschrittsanzeige
            if let liveStatus = webSocketService.liveStatus {
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
            } else if let errorMessage = webSocketService.errorMessage {
                // Fehleranzeige
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.headline)
                    .padding()
            } else {
                // Ladeanzeige
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(2)
                    Text("Warte auf Echtzeit-Daten...")
                        .foregroundColor(.gray)
                        .padding()
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

            .padding()
            .cornerRadius(10)
            .padding([.leading, .trailing])

            Spacer()

            // Umfrage beenden Button
            Button(action: closeVoting) {
                Text("Umfrage beenden")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
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
        print("Beenden der Umfrage für Voting ID: \(voting.id)")
        webSocketService.disconnect()
        onBack()
    }
}
