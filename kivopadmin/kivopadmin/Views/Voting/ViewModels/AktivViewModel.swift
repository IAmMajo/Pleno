// This file is licensed under the MIT-0 License.

import Foundation
import MeetingServiceDTOs
import SwiftUI

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

    func connectWebSocket() {
        guard voting.iVoted else { return }
        webSocketService.connect(to: voting.id)
        webSocketService.$liveStatus
            .receive(on: DispatchQueue.main)
            .assign(to: &$liveStatus)
    }

    func disconnectWebSocket() {
        webSocketService.disconnect()
    }

    func updateProgress() {
        guard let liveStatus = liveStatus else { return }
        let parts = liveStatus.split(separator: "/")
        if let currentValue = Int(parts.first ?? ""), let totalValue = Int(parts.last ?? "") {
            self.value = currentValue
            self.total = totalValue
            
            // ✅ `withAnimation` Problem gelöst (import SwiftUI und richtige Syntax)
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.8)) {
                    self.progress = Double(currentValue) / Double(totalValue)
                }
            }
        }
    }

    func closeVoting() {
        guard !isClosing else { return }
        isClosing = true

        VotingService.shared.closeVoting(votingId: voting.id) { result in
            DispatchQueue.main.async {
                self.isClosing = false
                switch result {
                case .success:
                    self.webSocketService.disconnect()
                    self.onBack()
                case .failure(let error):
                    self.errorMessage = "Fehler beim Schließen: \(error.localizedDescription)"
                }
            }
        }
    }
}
