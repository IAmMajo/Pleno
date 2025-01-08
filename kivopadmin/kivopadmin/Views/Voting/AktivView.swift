import SwiftUI

struct AktivView: View {
    let votingId: UUID
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
                                .blue.opacity(0.3),
                                lineWidth: 35
                            )
                            .overlay(
                                Text("\(value)/\(total)")
                                    .tracking(5)
                                    .font(.system(size: 50))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(UIColor.label).opacity(0.6).mix(with: Color.blue, by: 0.5))
                            )
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                .blue,
                                style: StrokeStyle(
                                    lineWidth: 35,
                                    lineCap: .round
                                )
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.easeOut(duration: 0.8), value: progress)
                    }
                    .padding(30)

                    Text("Es haben \(value) von \(total) Personen abgestimmt.")
                        .foregroundStyle(Color(UIColor.label).opacity(0.6))
                }
            } else if let errorMessage = webSocketService.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                Text("Warte auf Echtzeit-Daten...")
                    .foregroundColor(.gray)
                    .padding()
            }

            Spacer()

            // Button für die Rücknavigation
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
            webSocketService.connect(to: votingId)
        }
        .onDisappear {
            webSocketService.disconnect()
        }
        .onChange(of: webSocketService.liveStatus) { _, newLiveStatus in
            guard let newLiveStatus = newLiveStatus else { return }
            updateProgress(liveStatus: newLiveStatus)
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
        // Beispiel für API-Aufruf zum Beenden der Umfrage
        print("Beenden der Umfrage wurde gestartet.")
        onBack()
    }
}
