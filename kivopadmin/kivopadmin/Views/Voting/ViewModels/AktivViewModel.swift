// This file is licensed under the MIT-0 License.

import Foundation
import MeetingServiceDTOs
import SwiftUI

// ViewModel für die Live-Ansicht einer aktiven Abstimmung.
class AktivViewModel: ObservableObject {
    
    public let voting: GetVotingDTO
    
    @Published var liveStatus: String?
    @Published var errorMessage: String?
    @Published var isClosing = false
    @Published var progress: Double = 0
    @Published var value: Int = 0
    @Published var total: Int = 0
    
    let onBack: () -> Void
    private let webSocketService = WebSocketService()

    init(voting: GetVotingDTO, onBack: @escaping () -> Void) {
        self.voting = voting
        self.onBack = onBack
    }

    // Baut eine WebSocket-Verbindung auf, um Live-Daten zur Abstimmung zu erhalten.
    func connectWebSocket() {
        guard voting.iVoted else { return } // Verbindung nur herstellen, wenn der Nutzer abgestimmt hat
        webSocketService.connect(to: voting.id)
        webSocketService.$liveStatus
            .receive(on: DispatchQueue.main)
            .assign(to: &$liveStatus)
    }

    // Trennt die WebSocket-Verbindung.
    func disconnectWebSocket() {
        webSocketService.disconnect()
    }

    // Aktualisiert den Fortschritt der Abstimmung basierend auf den erhaltenen Live-Daten.
    func updateProgress() {
        guard let liveStatus = liveStatus else { return }
        let parts = liveStatus.split(separator: "/")
        
        if let currentValue = Int(parts.first ?? ""), let totalValue = Int(parts.last ?? "") {
            self.value = currentValue
            self.total = totalValue
            
            // Aktualisiert den Fortschrittswert mit einer sanften Animation.
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.8)) {
                    self.progress = Double(currentValue) / Double(totalValue)
                }
            }
        }
    }

    // Beendet die Abstimmung und trennt die WebSocket-Verbindung.
    func closeVoting() {
        guard !isClosing else { return }
        isClosing = true

        VotingService.shared.closeVoting(votingId: voting.id) { result in
            DispatchQueue.main.async {
                self.isClosing = false
                switch result {
                case .success:
                    self.webSocketService.disconnect()
                    self.onBack() // Zurück zur vorherigen Ansicht
                case .failure(let error):
                    self.errorMessage = "Fehler beim Schließen: \(error.localizedDescription)"
                }
            }
        }
    }
}
