// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



import Foundation
import MeetingServiceDTOs
import SwiftUI

// ViewModel für die Live-Ansicht einer aktiven Abstimmung.
class AktivViewModel: ObservableObject {
    
    // Die aktuelle Abstimmung, für die das Live-Tracking aktiv ist.
    public let voting: GetVotingDTO
    
    // Live-Status der Abstimmung (z. B. "1 von 3 hat abgestimmt").
    @Published var liveStatus: String?
    
    // Fehlermeldung, falls beim Laden oder Beenden der Abstimmung etwas schiefgeht.
    @Published var errorMessage: String?
    
    // Status, ob die Abstimmung gerade geschlossen wird (um doppelte Anfragen zu vermeiden).
    @Published var isClosing = false
    
    // Fortschritt der Abstimmung (zwischen 0 und 1).
    @Published var progress: Double = 0
    
    // Anzahl der bisherigen Stimmen.
    @Published var value: Int = 0
    
    // Gesamtanzahl der möglichen Stimmen.
    @Published var total: Int = 0
    
    // Aktion, die ausgeführt wird, wenn die Abstimmung geschlossen oder verlassen wird.
    let onBack: () -> Void
    
    // WebSocket-Service für die Live-Übertragung der Abstimmungsdaten.
    private let webSocketService = WebSocketService()

    // Initialisiert das ViewModel mit einer bestimmten Abstimmung.
    init(voting: GetVotingDTO, onBack: @escaping () -> Void) {
        self.voting = voting
        self.onBack = onBack
    }

    // MARK: - WebSocket-Verbindung

    /// Baut eine WebSocket-Verbindung auf, um Live-Daten zur Abstimmung zu erhalten.
    func connectWebSocket() {
        // Verbindung nur herstellen, wenn der Nutzer selbst abgestimmt hat.
        guard voting.iVoted else { return }
        webSocketService.connect(to: voting.id)
        
        // Reagiert auf Live-Updates der Abstimmung.
        webSocketService.$liveStatus
            .receive(on: DispatchQueue.main)
            .assign(to: &$liveStatus)
    }

    // Trennt die WebSocket-Verbindung, wenn sie nicht mehr benötigt wird.
    func disconnectWebSocket() {
        webSocketService.disconnect()
    }

    // MARK: - Live-Datenverarbeitung

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

            // 🟢 Setzt den `liveStatus`-Text in das gewünschte Format:
            // - "1 von 3 hat abgestimmt" für Singular
            // - "2 von 3 haben abgestimmt" für Plural
            DispatchQueue.main.async {
                self.liveStatus = "\(currentValue) von \(totalValue) \(currentValue == 1 ? "hat" : "haben") abgestimmt"
            }
        }
    }

    // MARK: - Abstimmung beenden

    // Beendet die Abstimmung und trennt die WebSocket-Verbindung.
    func closeVoting() {
        // Falls die Abstimmung bereits geschlossen wird, keine doppelte Anfrage senden.
        guard !isClosing else { return }
        isClosing = true

        VotingService.shared.closeVoting(votingId: voting.id) { result in
            DispatchQueue.main.async {
                self.isClosing = false
                switch result {
                case .success:
                    self.webSocketService.disconnect()
                    self.onBack() // Zurück zur vorherigen Ansicht wechseln.
                case .failure(let error):
                    self.errorMessage = "Fehler beim Schließen: \(error.localizedDescription)"
                }
            }
        }
    }
}
