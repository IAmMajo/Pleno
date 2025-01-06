//
//  VotingLiveStatusView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 06.01.25.
//

import SwiftUI
import MeetingServiceDTOs

struct VotingLiveStatusView: View {
    @ObservedObject var webSocketManager = WebSocketManager()
    let votingId: UUID
    
    var body: some View {
        VStack {
            if let liveStatus = webSocketManager.liveStatus {
                Text("Live Status: \(liveStatus)")
                    .font(.headline)
            } else if let votingResults = webSocketManager.votingResults {
                Text("Voting Results:")
                    .font(.headline)
                Text("\(votingResults)") // Customize the display as needed
            } else if let errorMessage = webSocketManager.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                Text("Connecting...")
                    .font(.subheadline)
            }
        }
        .onAppear {
            webSocketManager.connect(toVotingId: votingId)
        }
        .onDisappear {
            webSocketManager.disconnect()
        }
    }
}

#Preview {
   VotingLiveStatusView(votingId: UUID(uuidString: "4CF57888-E6AC-4B56-92D5-2D081480A10C")!)
}
